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
        return self.run_command(sys.executable, 'scripts/build-importer.py', *args, success=success)

    def test_generated_blocks_preserve_handwritten_documentation(self):
        for name in ('INSTALLATION.md', 'generated/BOOTSTRAP.md'):
            path = self.repo / name
            path.write_text('Handwritten introduction.\n' + path.read_text() + '\nHandwritten ending.\n')
        self.generate()
        for name in ('INSTALLATION.md', 'generated/BOOTSTRAP.md'):
            text = (self.repo / name).read_text()
            self.assertTrue(text.startswith('Handwritten introduction.\n'))
            self.assertTrue(text.endswith('\nHandwritten ending.\n'))
        self.generate('--check')

    def test_invalid_markers_fail_before_writing_artifacts(self):
        path = self.repo / 'INSTALLATION.md'
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
        source = self.repo / 'macros/common/fly.lua'
        source.write_bytes(source.read_bytes() + b'\n')
        bundle = (self.repo / 'generated/macros.txt').read_bytes()
        docs = (self.repo / 'INSTALLATION.md').read_bytes()
        self.generate('--check', success=False)
        self.assertEqual((self.repo / 'generated/macros.txt').read_bytes(), bundle)
        self.assertEqual((self.repo / 'INSTALLATION.md').read_bytes(), docs)
        self.generate()
        self.assertNotEqual((self.repo / 'generated/macros.txt').read_bytes(), bundle)
        paths = ['generated/macros.txt', 'generated/install.lua', 'generated/BOOTSTRAP.md',
                 'INSTALLATION.md', 'scripts/manifest.lua']
        first = {p: (self.repo / p).read_bytes() for p in paths}
        self.generate()
        self.assertEqual(first, {p: (self.repo / p).read_bytes() for p in paths})
        self.generate('--check')

    def test_hook_checks_index_and_never_stages_working_tree_changes(self):
        self.run_command('git', 'init', '-q')
        self.run_command('git', '-c', 'core.fsmonitor=false', 'add', '.')
        source = self.repo / 'macros/common/fly.lua'
        source.write_bytes(source.read_bytes() + b'\n')
        self.run_command('git', 'add', 'macros/common/fly.lua')
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
