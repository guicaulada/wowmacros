"""Regression checks for generation boundaries and staged-only validation."""
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class ToolingTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix='wowmacros-tools-')
        self.addCleanup(self.temporary.cleanup)
        self.repo = Path(self.temporary.name) / 'repo'
        shutil.copytree(ROOT, self.repo, ignore=shutil.ignore_patterns('.git', '__pycache__'))
        self.env = {k: v for k, v in os.environ.items() if not k.startswith('GIT_')}
        self.env['PYTHON'] = sys.executable

    def run_command(self, *args, success=True):
        result = subprocess.run(args, cwd=self.repo, env=self.env, text=True,
                                stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        if success:
            self.assertEqual(result.returncode, 0, result.stdout)
        else:
            self.assertNotEqual(result.returncode, 0, result.stdout)
        return result

    def generate(self, *args, success=True):
        return self.run_command(sys.executable, 'scripts/build.py', *args, success=success)

    def test_generated_blocks_preserve_handwritten_documentation(self):
        for name in ('docs/INSTALLATION.md', 'docs/BOOTSTRAP.md'):
            path = self.repo / name
            path.write_text('Handwritten introduction.\n' + path.read_text() + '\nHandwritten ending.\n')
        self.generate()
        for name in ('docs/INSTALLATION.md', 'docs/BOOTSTRAP.md'):
            text = (self.repo / name).read_text()
            self.assertTrue(text.startswith('Handwritten introduction.\n'))
            self.assertTrue(text.endswith('\nHandwritten ending.\n'))
        self.generate('--check')

    def test_source_comments_and_formatting_do_not_change_generated_output(self):
        for path in (self.repo / 'src').rglob('*.lua'):
            path.write_text('-- Readable source comment.\n--[=[ Another comment. ]=]\n\n' +
                            path.read_text() + '\n-- Trailing explanation.\n')
        self.generate('--check')

    def test_invalid_markers_fail_before_writing_artifacts(self):
        path = self.repo / 'docs/INSTALLATION.md'
        original = path.read_text()
        start = '<!-- BEGIN GENERATED: inventory -->'
        end = '<!-- END GENERATED: inventory -->'
        for broken in (original.replace(start, ''), original + start,
                       original.replace(start, 'TEMP').replace(end, start).replace('TEMP', end)):
            with self.subTest(document=broken[:30]):
                path.write_text(broken)
                bundle = (self.repo / 'generated/macros.txt').read_bytes()
                self.generate(success=False)
                self.assertEqual(path.read_text(), broken)
                self.assertEqual((self.repo / 'generated/macros.txt').read_bytes(), bundle)
        path.write_text(original)

    def test_stale_check_is_read_only_and_generation_is_repeatable(self):
        source = self.repo / 'src/cmds/fly.lua'
        source.write_bytes(source.read_bytes().replace(b'424', b'425'))
        bundle = (self.repo / 'generated/macros.txt').read_bytes()
        docs = (self.repo / 'docs/INSTALLATION.md').read_bytes()
        self.generate('--check', success=False)
        self.assertEqual((self.repo / 'generated/macros.txt').read_bytes(), bundle)
        self.assertEqual((self.repo / 'docs/INSTALLATION.md').read_bytes(), docs)
        self.generate()
        self.assertNotEqual((self.repo / 'generated/macros.txt').read_bytes(), bundle)
        paths = ['generated/macros.txt', 'generated/install.lua', 'docs/BOOTSTRAP.md',
                 'docs/INSTALLATION.md', 'generated/manifest.lua']
        first = {p: (self.repo / p).read_bytes() for p in paths}
        self.generate()
        self.assertEqual(first, {p: (self.repo / p).read_bytes() for p in paths})
        self.generate('--check')

    def test_new_sources_are_discovered_reassembled_and_removed(self):
        library = self.repo / 'src/libs/zshared.lua'
        command = self.repo / 'src/cmds/zexample.lua'
        core = self.repo / 'src/core/zexample.lua'
        library.write_text('return ' + repr('Olá | text ' * 80) + '\n')
        command.write_text('local text=wm.lib("zshared")\n' +
                           'local suffix=' + repr('x' * 600) + '\n' +
                           '_G.result=text .. msg .. suffix\n')
        # Even a short core source needs a loader if its string contains newlines.
        core.write_text('_G.coreResult=[=[first\nsecond]=]\n')
        # The bootstrap importer must also be able to use shared libraries.
        importer = self.repo / 'src/cmds/importmacros.lua'
        importer.write_text('assert(#wm.lib("zshared") > 255)\n' + importer.read_text())
        self.generate()
        self.run_command(os.environ.get('LUA', 'luajit'), 'tests/importer.lua')
        check = self.repo / 'check-new.lua'
        check.write_text(r'''local bodies=dofile("tests/read-bundle.lua")
for _,body in pairs(bodies) do assert(#body<=255) end
GetMacroBody=function(name)return bodies[name]end
SlashCmdList={}
assert(loadstring(bodies["~1.cmds"]:sub(6)))()
SlashCmdList.WOWMACROS_zexample("argument")
assert(result==string.rep("Olá | text ",80).."argument"..string.rep("x",600))
assert(loadstring(bodies["~1.zexample"]:sub(6)))()
assert(coreResult=="first\nsecond")
''')
        self.run_command(os.environ.get('LUA', 'luajit'), str(check))
        self.assertIn('src/cmds/zexample.lua', (self.repo / 'generated/manifest.lua').read_text())
        self.assertFalse((self.repo / 'generated/macros').exists())
        command.unlink()
        core.unlink()
        self.generate('--check', success=False)
        self.generate()
        self.assertNotIn('zexample', (self.repo / 'generated/manifest.lua').read_text())
        self.assertFalse((self.repo / 'generated/macros').exists())
        self.generate('--check')

    def test_capacity_and_name_failures_do_not_write_artifacts(self):
        path = self.repo / 'src/cmds/overflow.lua'
        bundle = (self.repo / 'generated/macros.txt').read_bytes()
        path.write_text('print("' + 'x' * (120 * 255) + '")')
        self.assertIn('account slots', self.generate(success=False).stdout)
        self.assertEqual((self.repo / 'generated/macros.txt').read_bytes(), bundle)
        path.unlink()
        path = self.repo / 'src/libs/thisnameistoolong.lua'
        path.write_text('print("hi")')
        self.assertIn('macro name', self.generate(success=False).stdout)
        self.assertEqual((self.repo / 'generated/macros.txt').read_bytes(), bundle)

    def test_hook_checks_index_and_never_stages_working_tree_changes(self):
        self.run_command('git', 'init', '-q')
        self.run_command('git', '-c', 'core.fsmonitor=false', 'add', '.')
        source = self.repo / 'src/cmds/fly.lua'
        source.write_bytes(source.read_bytes().replace(b'424', b'425'))
        self.run_command('git', 'add', 'src/cmds/fly.lua')
        self.generate()  # Working tree is fresh, but the staged artifacts are stale.
        tree = self.run_command('git', 'write-tree').stdout
        self.run_command('.githooks/pre-commit', success=False)
        self.assertEqual(self.run_command('git', 'write-tree').stdout, tree)
        self.generate('--check')
        self.run_command('git', 'add', '.')
        tree = self.run_command('git', 'write-tree').stdout
        staged_source = source.read_bytes()
        source.write_bytes(staged_source + b'\nnot valid Lua\n')  # Unstaged edits must stay separate.
        self.run_command('.githooks/pre-commit')
        self.assertEqual(source.read_bytes(), staged_source + b'\nnot valid Lua\n')
        self.assertEqual(self.run_command('git', 'write-tree').stdout, tree)


if __name__ == '__main__':
    unittest.main()
