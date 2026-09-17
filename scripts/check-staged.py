#!/usr/bin/env python3
"""Check the staged snapshot without modifying the index or working tree."""
import os
from pathlib import Path
import subprocess
import sys
import tempfile


def main():
    with tempfile.TemporaryDirectory(prefix='wowmacros-staged-') as directory:
        # Honor Git's index environment while exporting, including partial commits.
        subprocess.run(['git', '-c', 'core.fsmonitor=false', 'checkout-index',
                        '--all', '--prefix=' + directory + os.sep], check=True)
        if not (Path(directory) / 'Makefile').is_file():
            print('Stage the Makefile and validation tooling before committing.', file=sys.stderr)
            return 1
        # Do not let the hook's Git context leak into tools run in the snapshot.
        env = {key: value for key, value in os.environ.items() if not key.startswith('GIT_')}
        result = subprocess.run(['make', 'check'], cwd=directory, env=env)
        if result.returncode:
            print('Staged checks failed. Run make generate and make check, review the changes, '
                  'then stage the matching source, generated files, and documentation.', file=sys.stderr)
        return result.returncode


if __name__ == '__main__':
    sys.exit(main())
