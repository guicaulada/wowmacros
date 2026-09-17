#!/usr/bin/env python3
"""Compile src/{core,cmds,libs} into macro-sized programs and paste bundles."""
import argparse
import json
from pathlib import Path
import re

from compiler import compact, split

ROOT = Path(__file__).resolve().parents[1]
LIMIT = 255
CAPACITY = 120
# The chat bootstrap must work with zero installed macros.
BOOTSTRAP = '/run local e=CreateFrame("EditBox",nil,UIParent,"InputBoxTemplate") e:SetSize(600,300)e:SetPoint("CENTER")e:SetMultiLine(true)e:SetMaxLetters(0)e:SetScript("OnEnterPressed",function(s)assert(loadstring(s:GetText()))()s:Hide()end)e:SetFocus()'


def lua(value):
    if isinstance(value, str):
        # JSON string escaping is compatible with these ASCII names/source paths.
        return json.dumps(value, ensure_ascii=False)
    if isinstance(value, dict):
        return '{' + ','.join('[' + lua(k) + ']=' + lua(v) for k, v in sorted(value.items())) + '}'
    if isinstance(value, (list, tuple)):
        return '{' + ','.join(lua(v) for v in value) + '}'
    return str(value)


def literal(text):
    equals = '='
    while ']' + equals + ']' in text:
        equals += '='
    # An initial newline in long strings is ignored by Lua; preserve it explicitly.
    return '[' + equals + '[\n' + text + ']' + equals + ']'


def block(document, name, content):
    start, end = f'<!-- BEGIN GENERATED: {name} -->', f'<!-- END GENERATED: {name} -->'
    if document.count(start) != 1 or document.count(end) != 1:
        raise ValueError(f'Expected exactly one marker pair for {name}.')
    before, rest = document.split(start)
    if end not in rest:
        raise ValueError(f'Invalid marker order for {name}.')
    _, after = rest.split(end)
    return before + start + '\n' + content.rstrip('\n') + '\n' + end + after


def build():
    outputs, entries, bodies, programs = {}, [], {}, {}
    catalog = {'cmds': {}, 'libs': {}}
    sources = {}
    for kind in ('core', 'cmds', 'libs'):
        sources[kind] = sorted((ROOT / 'src' / kind).glob('*.lua'))
        for path in sources[kind]:
            if not re.fullmatch(r'[a-z][a-z0-9_]*', path.stem):
                raise ValueError(f'Invalid source filename: {path}')
    for required in ('core/cmds.lua', 'core/uninstall.lua', 'cmds/importmacros.lua'):
        if not (ROOT / 'src' / required).is_file():
            raise ValueError(f'Missing bootstrap source: {required}')

    def emit(name, body, source, kind):
        if name in bodies or '|' in name or len(name.encode()) > 16:
            raise ValueError(f'Duplicate/invalid macro name: {name}')
        if len(body.encode()) > LIMIT:
            raise ValueError(f'Macro exceeds {LIMIT} bytes: {name}')
        bodies[name] = body
        entries.append([name, source, kind, len(body.encode())])

    def pieces(kind, prefix, code, source, first=None):
        chunks = split(code)
        for index, chunk in enumerate(chunks, 1):
            name = first if index == 1 and first else f'~3.{prefix}.{index:03}'
            directory = 'libs' if kind == 'libs' and index == 1 else 'chunks'
            emit(name, chunk, source, directory)
        descriptor = [prefix, len(chunks)]
        if first:
            descriptor.append(first)
        return descriptor

    for kind, initial in (('libs', 'l'), ('cmds', 'c')):
        for index, path in enumerate(sources[kind], 1):
            source = path.relative_to(ROOT).as_posix()
            code = compact(path.read_text())
            if not code:
                raise ValueError(f'Empty source: {source}')
            programs[source] = code
            first = '~2.' + path.stem if kind == 'libs' else None
            catalog[kind][path.stem] = pieces(kind, f'{initial}{index:03}', code, source, first)

    for index, path in enumerate(sources['core'], 1):
        source = path.relative_to(ROOT).as_posix()
        text = path.read_text()
        if path.stem == 'cmds':
            if text.count('-- @catalog') != 1:
                raise ValueError('src/core/cmds.lua needs exactly one -- @catalog directive')
            text = text.replace('-- @catalog', 'local catalog=' + lua(catalog))
        code = compact(text)
        if not code:
            raise ValueError(f'Empty source: {source}')
        programs[source] = code
        body = '/run ' + code
        if len(body.encode()) > LIMIT or '\n' in code or '\r' in code:
            prefix, count = pieces('core', f'k{index:03}', code, source)
            body = (f'/run local t={{}}for i=1,{count} do '
                    f't[i]=assert(GetMacroBody(("~3.{prefix}.%03d"):format(i)),"Missing core chunk")'
                    'end assert(loadstring(table.concat(t)))()')
        emit('~1.' + path.stem, body, source, 'core')

    if len(entries) > CAPACITY:
        raise ValueError(f'Build requires {len(entries)} account slots; budget is {CAPACITY}.')
    outputs['generated/catalog.lua'] = '-- Generated; do not edit.\nreturn ' + lua(catalog) + '\n'
    outputs['generated/manifest.lua'] = '-- Generated: name, source, category, bytes.\nreturn {\n' + ''.join(
        '  ' + lua(entry) + ',\n' for entry in entries) + '}\n'
    icons = json.loads((ROOT / 'scripts/icons.json').read_text())
    records = []
    for name, source, kind, size in entries:
        records.append(':'.join(s.encode().hex() for s in (name, icons[kind], bodies[name])))
    bundle = f'WOWMACROS3 {len(records)}\n' + '\n'.join(records) + '\nEND\n'
    outputs['generated/macros.txt'] = bundle
    outputs['generated/bootstrap.lua'] = BOOTSTRAP + '\n'
    # Hex protects arbitrary strings (including pipes/tabs) during EditBox paste.
    libraries = '{' + ','.join('[' + lua(path.stem) + ']=' + lua(programs[path.relative_to(ROOT).as_posix()].encode().hex())
                             for path in sources['libs']) + '}'
    outputs['generated/install.lua'] = (
        '-- Paste into the bootstrap text box, press Enter, then click Import.\n'
        'if WoWMacrosImport then WoWMacrosImport:Hide() WoWMacrosImport=nil end\n'
        'local function decode(s)return(s:gsub("..",function(h)return string.char(tonumber(h,16))end))end\n'
        'local sources=' + libraries + '\n'
        'local wm,cache,loading={},{},{}\n'
        'function wm.lib(n)\n'
        'if cache[n]~=nil then return cache[n] end\n'
        'assert(not loading[n],"Circular library: "..n)\n'
        'local s=decode(assert(sources[n],"Unknown library: "..n))\n'
        'local factory=assert(loadstring("return function(wm) "..s.." end"))()\n'
        'loading[n]=true\n'
        'local ok,v=pcall(factory,wm)\n'
        'loading[n]=nil assert(ok,v) assert(v~=nil,"Library returned nil: "..n)\n'
        'cache[n]=v return v end\n'
        'assert(loadstring("return function(msg,wm) "..decode(' +
        lua(programs['src/cmds/importmacros.lua'].encode().hex()) + ').." end"))()("",wm)\n'
        'WoWMacrosImport.Input:SetText(' + literal(bundle) + ')\n')
    outputs['docs/BOOTSTRAP.md'] = block((ROOT / 'docs/BOOTSTRAP.md').read_text(),
        'bootstrap-chat', '```text\n' + outputs['generated/bootstrap.lua'] + '```')
    outputs['docs/BOOTSTRAP.md'] = block(outputs['docs/BOOTSTRAP.md'],
        'uninstall-chat', '```text\n' + bodies['~1.uninstall'] + '\n```')
    documentation = (ROOT / 'docs/INSTALLATION.md').read_text()
    documentation = block(documentation, 'icons', '\n'.join(
        ['| Generated category | Managed icon |', '| --- | --- |'] +
        [f'| `{kind}` | `{icon}` |' for kind, icon in icons.items()]))
    rows = ['| In-game name | Bytes | Source |', '| --- | ---: | --- |']
    for name, source, kind, size in entries:
        rows.append(f'| `{name}` | {size} | [{source}](../{source}) |')
    maximum = max(entry[3] for entry in entries)
    rows += ['', f'{len(entries)}/{CAPACITY} account slots; {len(programs)} source files. '
                  f'Every stored macro fits within {LIMIT} bytes (largest: {maximum}).']
    outputs['docs/INSTALLATION.md'] = block(documentation, 'inventory', '\n'.join(rows))
    return outputs, len(entries)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    try:
        outputs, count = build()
    except (ValueError, AssertionError) as error:
        raise SystemExit(str(error))
    stale = [path for path, text in outputs.items()
             if not (ROOT / path).exists() or (ROOT / path).read_bytes() != text.encode()]
    if args.check:
        if stale:
            raise SystemExit('Generated files are stale; run make generate and stage the results:\n' +
                             '\n'.join(stale))
    else:
        for path, text in outputs.items():
            target = ROOT / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(text.encode())
    print(f'{"Checked" if args.check else "Built"} {count}/{CAPACITY} macros; all at most {LIMIT} bytes.')


if __name__ == '__main__':
    main()
