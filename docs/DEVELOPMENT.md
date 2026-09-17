# Development and authoring

## Source layout

```text
src/
├── core/   # standalone system entry points: cmds, uninstall
├── cmds/   # one complete Lua file per slash command, including fly and mount
└── libs/   # reusable Lua libraries
scripts/    # compiler, generation, icon configuration, staged checks
docs/       # installation, command reference, inventory, and this guide
generated/  # bootstrap line, catalog, manifest, installer, and paste bundle
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
| `docs/BOOTSTRAP.md` | Handwritten installation guide with generated bootstrap and uninstall code blocks. |

`make generate` creates the Lua/text artifacts and refreshes only the marked
sections of `docs/BOOTSTRAP.md` and `docs/INSTALLATION.md`. Tests use the catalog and manifest;
you do not paste either file into the game.


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

