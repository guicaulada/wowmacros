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
# Generate a copyable bootstrap guide so the one-time install needs no helper pastes.
outputs['generated/BOOTSTRAP.md'] = '''# One-time installation (no addon)

1. Create a general/account macro named `{import}` and paste this entire line:

```text
''' + outputs['macros/core/import.lua'] + '''```

2. Click `{import}` to open the paste box.
3. Copy **all** of [install.lua](install.lua), paste it into the box, and press Enter.
   This step executes the generated Lua installer from this repository.
4. The importer window opens with the full bundle already filled in. Click **Import**.
5. Click `{cmds}` to register `/importmacros` and the other commands.

For later updates, run `/importmacros`, paste all of [macros.txt](macros.txt), and
click **Import**, then click `{cmds}`. If importer code itself changed, `/reload`
and click `{cmds}` to use the new importer implementation.

The bootstrap is only for this repository's generated installer; do not paste
arbitrary Lua into it. Normal update bundles are parsed as data and are not executed.
For a fresh reset, first create and run `{clear}` using
[clear.lua](../macros/core/clear.lua), outside combat. It deletes **all general
macros whose names start with `{`, `[`, or `|`**, including itself and `{import}`.
It preserves other general macros (including `fly` and `run`) and all character
macros. Run `/reload` to discard old registered commands, then start at step 1.
No existing bootstrap or helper macro is required. This is a fresh installation,
not a name migration; handle existing `fly` and `run` casing manually.

For a retry, paste the latest `install.lua` into `{import}` again. The installer
replaces the old window and callbacks. Old `WOWMACROS1` and `WOWMACROS2` bundles
are no longer accepted.

The `WOWMACROS3` format encodes names, icons, and bodies as hexadecimal, separated
by a colon. It has no raw pipe characters or tabs for the text box to reinterpret.
All stored macros, including the bootstrap and importer helpers, fit within 255 bytes.
'''
# Keep the installation inventory and icon policy in sync with the bundle.
def code(value):
    return '`' + value.replace('|', r'\|') + '`'

lines = [
    '# Installation', '',
    'For GeForce Now and bulk updates, follow the [bootstrap guide](generated/BOOTSTRAP.md).',
    'To reset first, manually create `{clear}` from [clear.lua](macros/core/clear.lua)',
    'and run it outside combat. It deletes all general macros beginning with `{`, `[`, or `|`,',
    'including itself. Other general macros and all character macros are preserved.',
    'Run `/reload`, then create `{import}` from [import.lua](macros/core/import.lua).',
    'Click it, paste [install.lua](generated/install.lua), press Enter, and click Import.',
    'Then click `{cmds}`. Later updates use `/importmacros` with [macros.txt](generated/macros.txt).', '',
    'All entries are general/account macros. Names use lowercase, braces, and square brackets. Imports match exact names only.',
    'Commands also require `{cmds}` and `{[run]}`. The table lists direct dependencies.',
    'Core names use `{name}`, shared libraries `{[name]}`, commands `[name]`,',
    'and command helpers `[[name]]`. No names contain pipes. No renames or migrations are performed.',
    'Byte counts include all newlines. Do not add `/run` to raw Lua libraries or command bodies.', '',
    '| Directory | Managed icon |', '| --- | --- |',
]
for prefix, icon in icons.items():
    lines.append(f'| {code(prefix)} | {code(icon)} |')
lines += [
    '', 'The most specific directory wins. Existing icons in other directories are preserved;',
    'new macros in those directories use the question-mark icon. Imports update managed icons',
    'even when macro bodies have not changed. No macros are deleted by the importer.', '',
    '| In-game name | File | Bytes | Direct dependencies, in order |',
    '| --- | --- | ---: | --- |',
]
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
lines += ['', f'All {len(entries)} files fit within 255 bytes; the largest is {maximum} bytes.', '',
          'The importer targets Retail WoW. Its version-2 bootstrap and import flow were',
          'reported working in-game; version-3 icon updates still need in-game verification.']
outputs['INSTALLATION.md'] = '\n'.join(lines) + '\n'

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
    raise SystemExit('Generated files are stale; run python3 scripts/build-importer.py:\n' + '\n'.join(stale))
print(f'{"Checked" if args.check else "Built"} {len(chunks)} importer helpers, {len(records)} macros, {len(bundle.encode())} bundle bytes.')
