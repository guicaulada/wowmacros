# World of Warcraft Macros

If replacing an older naming scheme, run its existing uninstall/reset macro before `/reload`
and reinstalling. The new `~1.uninstall` only removes the new reserved prefixes.

An addon-free macro system for Retail WoW, including GeForce Now. Write each command
or library as one Lua file. The generator compacts the code and splits it into
stored macros of at most **255 bytes**; the runtime joins the pieces before compiling
and executing the complete source. Local variables, long lines, and strings can
span chunk boundaries. Comments and unnecessary whitespace are removed during
generation; quoted and long-bracket string contents are preserved. Source code can
use normal formatting and explanatory comments.

## Source layout

```text
src/
├── core/   # standalone system entry points: cmds, uninstall
├── cmds/   # one complete Lua file per slash command, including fly and mount
└── libs/   # reusable Lua libraries
scripts/    # compiler, generation, icon configuration, staged checks
generated/  # catalog, manifest, bootstrap guide/line, installer, and paste bundle
```

Edit `src/`; macro chunks are kept in memory and packed directly into the bundle. There are no hand-maintained helper chunks,
`#cmd` directives, `#run` lists, or source manifest. Files are discovered automatically.
Generated files remain committed so they are ready to paste without running tools.

| Generated artifact | Purpose |
| --- | --- |
| `install.lua` | Executable chat-bootstrap installer with the full bundle included. |
| `macros.txt` | Data-only bundle for `/importmacros`; also decoded by tests. |
| `bootstrap.lua` | Pasteable `/run` chat line, used by the bootstrap guide and tests. |
| `catalog.lua` | Command/library chunk descriptors for validation; the runtime embeds its own copy in the bundle. |
| `manifest.lua` | Macro names, source paths, categories, and byte counts for validation. |
| `BOOTSTRAP.md` | Handwritten installation guide with generated bootstrap and uninstall code blocks. |

`make generate` creates the Lua/text artifacts and refreshes only the marked
sections of `BOOTSTRAP.md` and `INSTALLATION.md`. Tests use the catalog and manifest;
you do not paste either file into the game.


## Installation

Follow the [bootstrap guide](generated/BOOTSTRAP.md). Paste its `/run` line into WoW
chat to open the text box, paste the generated installer, and press Enter. Then
click **Import**. No macro needs to be created manually.
Then click `~1.cmds` to register commands. Click `~1.cmds` again after every login/reload.
Run `/cmds` to list all installed system commands on one line, separated by spaces.
No addon or access to WoW's filesystem is needed.

For this layout change, run `~1.uninstall`, `/reload`, then follow the bootstrap guide
from scratch. `~1.uninstall` deletes **all account macros starting with `~1.`, `~2.`, or `~3.`**,
including itself. Other account macros and character macros remain. Remove the old
standalone `fly` and `run` macros manually; use `/fly` and `/mount` instead.
Command shortcuts are not generated. To put a command on an action bar, create
your own macro containing its slash command, such as `/fly`. Choose a name without
a system prefix (for example, `Fly`) so `~1.uninstall` preserves it.

For later body-only updates, `/importmacros` accepts [generated/macros.txt](generated/macros.txt).
Click **Import**, then `~1.cmds`. If the importer itself changed, `/reload` and click
`~1.cmds` to discard the old importer window. When sources are added, removed, or
shrink, use the fresh-reset flow: chunk IDs can shift, and the importer does not
delete obsolete macros. Imports only update exact names or create new entries;
there are no renames or migrations.

The [installation inventory](INSTALLATION.md) lists every generated macro and its
source. Names are lowercase and pipe-free. The shared `~` prefix sorts after
ordinary ASCII names such as `FLY`; numeric groups order core entries (`~1.`),
library entries (`~2.`), then all code chunks (`~3.`):

| Role | Example | Icon |
| --- | --- | --- |
| Core entry | `~1.cmds` | Red punchcard |
| Library first chunk | `~2.mount` | White punchcard |
| Additional library chunk | `~3.l003.002` | Yellow punchcard |
| Core/command code chunk | `~3.c006.001` | Yellow punchcard |

Icon settings live in [scripts/icons.json](scripts/icons.json). The importer validates
the whole bundle, byte lengths, duplicates, capacity, and combat status before writing.
If a write fails, it stops and reports it; earlier changes remain. Reimporting the
same bundle skips unchanged entries. The normal hex bundle is data; the initial
bootstrap executes this repository's generated Lua installer.

See the [command reference](src/cmds/README.md) for the installed commands.

## Writing a command

Create `src/cmds/hello.lua` with ordinary Lua, without `/run`:

```lua
local text = msg ~= "" and msg or "world"
print("Hello, " .. text)
```

Run `make generate`. This creates only the code chunks needed to register the
command. After installation and `~1.cmds`, `/hello Gui`
prints `Hello, Gui`. `msg` is the slash-command argument; `wm` is the shared runtime.

Filenames use lowercase letters, numbers, and underscores, starting with a letter.
Core and library source names allow up to 13 ASCII characters, because their
three-character prefixes must fit the 16-byte in-game name limit. Commands use numbered chunk names
and have no generated shortcut name. Source files can exceed 255 bytes;
the total generated collection must still fit WoW's 120 account slots. The importer
also checks remaining room alongside your unrelated account macros.

## Writing a library

A library returns a value, usually a function. For example, `src/libs/greeting.lua`:

```lua
return function(name)
    return "Hello, " .. name
end
```

A command uses it with `print(wm.lib("greeting")(msg))`. Libraries receive `wm` too,
so they can use other libraries. Return values are cached until `~1.cmds` runs again;
read changing game state inside the returned function. Missing libraries and circular
loads produce errors. Local variables belong to their source file; return values
explicitly instead of relying on textual includes.

Core files are standalone Lua programs. Small single-line programs become `/run`
macros; larger programs get a self-contained loader and generated chunks. They do
not depend on the command runtime being initialized. `core/cmds.lua` has one compiler
insertion marker, `-- @catalog`. The chat bootstrap seed remains
independent of all installed macros.

## Development

Install Python 3, LuaJIT (or Lua 5.1), and Make:

```sh
make install-hooks   # once per clone
make generate        # after editing sources or icons
make check           # freshness, byte limits, syntax, runtime/importer regressions
make test-tooling    # compiler boundaries, generation, and staged-hook regressions
```

Use `make LUA=lua PYTHON=python3 check test-tooling` to override executables.
`make generate` updates the catalog/manifest, paste bundles, and sections
between `<!-- BEGIN GENERATED: name -->` and `<!-- END GENERATED: name -->` in the
documentation. Surrounding prose is preserved. Missing or malformed markers fail
before artifacts are written. Tests decode `generated/macros.txt` directly, so
individual chunk files are never created, even temporarily.

The pre-commit hook checks **the staged snapshot**, without rewriting or staging files.
If outputs are stale, run `make generate`, review and stage the matching changes, then
retry. Enable it in each clone with `make install-hooks`; CI runs `make check test-tooling`.

`/loadmacros` replaces character macros with the saved class snapshot. `/loadbars`
restores spells, macros, items, and empty slots across slots 1–240 after a preflight.
Restore macros before bars that reference them. Both restores require being out of
combat. External macro references `HS`, `TRNK1`, and `TRNK2` keep their configured names.

The importer previously worked in-game; this generic compiler/runtime has been tested
with mocked WoW APIs and still needs an in-game check. Tests cannot establish live
protected-action or persistence behavior.

## License

[MIT](LICENSE).
