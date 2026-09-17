#!/usr/bin/env python3
"""Build macro-sized importer fragments and paste bundles. Run from any directory."""
from pathlib import Path
import argparse
import re
import json

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--check', action='store_true', help='Fail if generated files are stale.')
args = parser.parse_args()
outputs = {}
source = (ROOT / 'src/importer.lua').read_text()
chunks = []
chunk = ''
for line in source.splitlines():
    line = line.strip()
    if not line or line.startswith('--'):
        continue
    line += '\n'
    assert len(line.encode()) <= 255, f'Source line too long: {line}'
    if len((chunk + line).encode()) > 255:
        chunks.append(chunk)
        chunk = ''
    chunk += line
if chunk:
    chunks.append(chunk)
helpers = []
for i, chunk in enumerate(chunks, 1):
    name, path = f'[[im{i:02}]]', f'macros/cmds/libs/im{i:02}.lua'
    helpers.append((name, path))
    outputs[path] = chunk
command = '#cmd importmacros\n#run ' + ' '.join(n for n, _ in helpers) + '\n'
assert len(command.encode()) <= 255, 'Too many importer helpers for one command macro.'
outputs['macros/cmds/importmacros.lua'] = command
# One-time bootstrap: paste the generated first-party Lua installer and press Enter.
outputs['macros/core/import.lua'] = '/run local e=CreateFrame("EditBox",nil,UIParent,"InputBoxTemplate") e:SetSize(600,300)e:SetPoint("CENTER")e:SetMultiLine(true)e:SetMaxLetters(0)e:SetScript("OnEnterPressed",function(s)assert(loadstring(s:GetText()))()s:Hide()end)e:SetFocus()\n'
manifest = (ROOT / 'scripts/manifest.lua').read_text()
start, end = '-- BEGIN GENERATED IMPORTER', '-- END GENERATED IMPORTER'
entries = [('{import}', 'macros/core/import.lua'), ('[importmacros]', 'macros/cmds/importmacros.lua')] + helpers
section = start + '\n' + ''.join(f'  {{"{n}", "{p}"}},\n' for n,p in entries) + '  ' + end
if start in manifest:
    manifest = re.sub(re.escape(start) + r'.*?' + re.escape(end), lambda _: section, manifest, flags=re.S)
else:
    manifest = manifest.rstrip()[:-1] + '  ' + section + '\n}\n'
outputs['scripts/manifest.lua'] = manifest
entries = re.findall(r'\{"([^"]+)", "([^"]+)"\}', manifest)
icons = json.loads((ROOT / "scripts/icons.json").read_text())
records = []
for name, path in entries:
    body = outputs[path].encode() if path in outputs else (ROOT / path).read_bytes()
    assert name == name.lower() and "|" not in name, name
    assert len(name.encode()) <= 16 and len(body) <= 255, (name, len(body))
    icon = next((icons[prefix] for prefix in sorted(icons, key=len, reverse=True) if path.startswith(prefix)), '')
    records.append(name.encode().hex() + ':' + icon.encode().hex() + ':' + body.hex())
bundle = f'WOWMACROS3 {len(records)}\n' + '\n'.join(records) + '\nEND\n'
outputs['generated/macros.txt'] = bundle
# Bootstrap runs only repository code. The regular importer parses data, never Lua.
# Long-string delimiters are chosen so bundle contents cannot close the literal.
delim = '='
while ']' + delim + ']' in bundle:
    delim += '='
outputs['generated/install.lua'] = ('-- Paste into {import} and press Enter; then click Import.\n'
    + 'if WoWMacrosImport then WoWMacrosImport:Hide() WoWMacrosImport=nil end\n'
    + '(function()\n' + source + '\nend)()\n'
    + 'WoWMacrosImport.Input:SetText([' + delim + '[' + bundle + ']' + delim + '])\n')
def generated_block(document, name, content):
    """Replace exactly one marked section, preserving all handwritten text."""
    start = f'<!-- BEGIN GENERATED: {name} -->'
    end = f'<!-- END GENERATED: {name} -->'
    if document.count(start) != 1 or document.count(end) != 1:
        raise SystemExit(f'Expected exactly one marker pair for {name}.')
    before, rest = document.split(start)
    if end not in rest:
        raise SystemExit(f'Invalid marker order for {name}.')
    _, after = rest.split(end)
    return before + start + '\n' + content.rstrip('\n') + '\n' + end + after

outputs['generated/BOOTSTRAP.md'] = generated_block(
    (ROOT / 'generated/BOOTSTRAP.md').read_text(), 'bootstrap-macro',
    '```text\n' + outputs['macros/core/import.lua'] + '```')

def code(value):
    return '`' + value.replace('|', r'\|') + '`'

icon_lines = ['| Directory | Managed icon |', '| --- | --- |']
for prefix, icon in icons.items():
    icon_lines.append(f'| {code(prefix)} | {code(icon)} |')
installation = generated_block((ROOT / 'INSTALLATION.md').read_text(),
                               'icons', '\n'.join(icon_lines))
lines = ['| In-game name | File | Bytes | Direct dependencies, in order |',
         '| --- | --- | ---: | --- |']
maximum = 0
for name, path in entries:
    body = outputs[path] if path in outputs else (ROOT / path).read_text()
    size = len(body.encode())
    maximum = max(maximum, size)
    dependencies = []
    for match in re.finditer(r'^#run ([^\r\n]+)', body, re.M):
        dependencies.extend(match.group(1).split())
    if name == '{cmds}':
        dependencies = ['{[run]}']
    elif path.startswith('macros/common/'):
        dependencies = re.findall(r'GetMacroBody\("([^"\n]+)"\)', body)
    deps = ', '.join(code(dep) for dep in dependencies) or '—'
    lines.append(f'| {code(name)} | [{path}]({path}) | {size} | {deps} |')
lines += ['', f'All {len(entries)} files fit within 255 bytes; the largest is {maximum} bytes.']
outputs['INSTALLATION.md'] = generated_block(installation, 'inventory', '\n'.join(lines))

stale = []
for path, content in outputs.items():
    destination = ROOT / path
    if args.check:
        if not destination.exists() or destination.read_bytes() != content.encode():
            stale.append(path)
    else:
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(content.encode())
expected = {p for _,p in helpers}
for path in (ROOT / 'macros/cmds/libs').glob('im[0-9][0-9].lua'):
    if str(path.relative_to(ROOT)) not in expected:
        if args.check:
            stale.append(str(path.relative_to(ROOT)))
        else:
            path.unlink()
if stale:
    raise SystemExit('Generated files are stale; run make generate, then stage the updated files:\n' + '\n'.join(stale))
print(f'{"Checked" if args.check else "Built"} {len(chunks)} importer helpers, {len(records)} macros, {len(bundle.encode())} bundle bytes.')
