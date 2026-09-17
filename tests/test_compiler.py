"""Exercise lexical compaction and reconstruction with the Lua runtime."""
import os
from pathlib import Path
import subprocess
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'scripts'))
from compiler import compact, split
from build import literal


class CompilerTests(unittest.TestCase):
    def execute(self, source):
        return subprocess.run([os.environ.get('LUA', 'luajit'), '-'], input=source,
                              text=True, capture_output=True)

    def check_program(self, source):
        expected = self.execute(source)
        self.assertEqual(expected.returncode, 0, expected.stderr)
        code = compact(source)
        chunks = split(code)
        self.assertEqual(''.join(chunks), code)
        self.assertTrue(all(len(chunk.encode()) <= 255 for chunk in chunks))
        # Actual loader concatenates fragments before compiling, without separators.
        loader = 'assert(loadstring(table.concat({' + ','.join(map(literal, chunks)) + '})))()'
        actual = self.execute(loader)
        self.assertEqual(actual.returncode, 0, actual.stderr)
        self.assertEqual(actual.stdout, expected.stdout)

    def test_lexical_boundaries_and_strings(self):
        self.check_program('''
            -- Comments must not merge adjacent tokens.
            local n = 0 for i = 1, 3 do n = n + 1 end
            local a = 1 .. "x"
            local b = 1 - -2
            local c = 0x1 and 2
            local d = .5 + 1e-2
            local e = [==[long ]=] string -- not a comment]==]
            local f = "escaped \\\" quote and \\\\ slash"
            --[=[ long comment ]=]
            print(n, a, b, c, d, e, f)
        ''')

    def test_long_line_long_string_unicode_and_scope_across_chunks(self):
        self.check_program('local message = [=[' + 'Olá | world\t\n' * 80 +
                           ']=]\nlocal suffix="done"\nprint(message .. suffix)')
        self.check_program('local t={' + ','.join(str(i) for i in range(400)) +
                           '} local total=0 for _,n in ipairs(t) do total=total+n end print(total)')

    def test_utf8_byte_boundaries(self):
        for size in (1, 254, 255, 256, 510, 511):
            text = 'x' * size + 'é😀' * 100
            chunks = split(text)
            self.assertEqual(''.join(chunks), text)
            self.assertTrue(all(len(c.encode()) <= 255 for c in chunks))

    def test_unterminated_literals_rejected(self):
        for text in ('"oops', '[=[oops', '--[=[oops'):
            with self.assertRaises(ValueError):
                compact(text)


if __name__ == '__main__':
    unittest.main()
