# World of Warcraft Macros Collection

Welcome to my World of Warcraft macros repository! This project is organized to help manage and utilize various macros efficiently. The macros are organized into different folders based on their function, and naming conventions are used to control their order for easy access and management within the game.

## Project Structure

```plaintext
macros/
├── core/       # {cmds}, {import}, and {clear}
│   └── libs/   # shared libraries
├── common/     # fly and run click/shortcut macros
└── cmds/       # slash commands
    └── libs/   # command helpers
```

### Explanation

- **macros/**: The main directory containing all macros.
  - **core/**: System setup and bootstrap macros.
    - **libs/**: Shared libraries for command expansion, persistence, loadouts, and mounts.
  - **common/**: Click/shortcut gameplay macros.
  - **cmds/**: Folder for macros using the `#cmd` mechanic.
    - **libs/**: Subfolder within `cmds` for additional libraries or files executed by the commands.
  - All other macros.

### Naming Conventions

All repository-managed names are lowercase and contain no pipe characters.
WoW uses pipes for text formatting, so plain braces and square brackets identify
roles without consuming letters or collapsing delimiters in displayed labels.

- **Core:** `{cmds}`, `{import}`, `{clear}`.
- **Shared libraries:** `{[run]}`, `{[save]}`, `{[mount]}`.
- **Commands:** `[way]`, `[accountbars]`.
- **Command helpers:** `[[accountbars1]]`, `[[im01]]`.
- **Click/shortcut macros:** `fly`, `run`.

Imports match exact stored names only. There are no casing fixes, renames, or
legacy-name migrations. Use `{clear}` before reinstalling the system. Existing
`fly`/`run` casing differences can be handled manually. References to external
user macros `HS`, `TRNK1`, and `TRNK2` retain their configured names.

## Engine Macros

Engine macros are underlying macros that need to be called only once every reload or login. They don't take any direct action in-game, such as summoning mounts or casting spells. Instead, they are used to process other macros and perform code generation. Engine macros enable the framework of command creation and other frameworks.

The `cmds` macro is a prime example of an engine macro. It processes all macros that start with `#cmd <command>` and converts them into usable in-game commands. This macro needs to be called once per session (on reload or login) to ensure the command framework is properly initialized.

### Characteristics

- **No Direct Action**: Unlike regular macros, engine macros don't perform in-game actions like summoning mounts.
- **Once per Session**: They need to be called only once per session, typically during a reload or login.
- **Framework Enablers**: They are essential for setting up the framework that other macros rely on, including command creation and macro processing.

## The `#cmd` Mechanic

Macros starting with `#cmd <command>` will be converted into a command by the `cmds` macro. This feature allows you to create custom commands that can be invoked directly in the game. 

### How It Works

- **Command Conversion**: The `cmds` macro processes any macro that begins with `#cmd <command>`, effectively transforming it into a usable in-game command.

- **Code Injection with `#run`**: Command macros that utilize the `#cmd` mechanic can also leverage the `#run <macro_name>` function to inject code from other macros within their scope. You can even run multiple macros in sequence by specifying them in the format `#run macro1 macro2 macro3`. This allows for modular macro creation, where smaller pieces of code can be reused across multiple commands.

### Example

```plaintext
#cmd mycommand
#run macro1 macro2 macro3
print("This is my custom command!")
```

In this example:

- The `#cmd mycommand` will create a command named `mycommand`.
- The `#run macro1 macro2 macro3` will inject the contents of `macro1`, `macro2`, and `macro3` into this command's execution, in that order.

## How to Use

**For GeForce Now or bulk updates:** follow the [one-time importer setup](generated/BOOTSTRAP.md).
It requires manually creating just one macro, `{import}`, and pasting the generated
installer once. Click Import to install the collection, then click `{cmds}`.
Afterward, use `/importmacros` and paste [generated/macros.txt](generated/macros.txt)
to update existing account macros by name and create missing ones. No addon
or access to WoW's filesystem is needed. Icons follow [scripts/icons.json](scripts/icons.json): core macros use
`inv_misc_punchcards_red`, shared libraries in `macros/core/libs` use
`inv_misc_punchcards_white`, commands use `inv_misc_punchcards_blue`, and command
helpers use `inv_misc_punchcards_yellow`. Existing macros receive these icons even
when their bodies are unchanged. Icons in other directories, unrelated account
macros, and character macros are preserved; new macros without a category icon
use the question-mark icon.

The normal `WOWMACROS3` bundle is data, not executable Lua. Macro names, icon names, and
bodies are hex-encoded, with colon separators, to avoid raw pipes and tabs in the
text box. The one-time bootstrap executes
this repository's generated installer to open the importer. The importer checks
the complete bundle, duplicate names, body sizes, available account slots, and
combat status before writing. It does not delete macros. If WoW rejects a write
mid-import, it stops and reports the failure; earlier changes remain. Importing
the same bundle again skips unchanged macros.

For manual installation:

1. Use the [installation table](INSTALLATION.md) to create **general/account macros** with the exact names shown, including case and punctuation.
2. Copy each file's complete contents into its macro. All files fit within **255 bytes, including newlines**. The libraries must also be stored as separate macros.
3. Install the dependencies listed for each macro you use. `fly` and `run` now require `{[mount]}`; they do not require the command engine.
4. Click `{cmds}` after login/reload and after editing command macros or their libraries to register the slash commands.

Command bodies and libraries contain raw Lua, without `/run`. Put each `#run`
directive on its own line. Multiple directive lines are supported; nested
directives inside libraries are not. Missing libraries produce a `Missing macro`
error when the engine is run. Correct the name or install the dependency, then
run the engine again.

`/loadmacros` replaces all 18 character macro slots with the saved class snapshot.
General macros are untouched. `/loadbars` restores spells, macros, items, and
empty slots across slots 1–240. It checks the snapshot first and aborts without
changing bars if an action type is unsupported or an action cannot be picked up.
Restore macros before restoring bars that reference them. Both restores must run
outside combat.

## Development and validation

Install Python 3, LuaJIT (or Lua 5.1), and Make. Enable the repository's commit hook
once per clone:

```sh
make install-hooks
```

Edit macros, `src/importer.lua`, `scripts/manifest.lua`, or `scripts/icons.json`, then:

```sh
make generate
make check
```

`make generate` refreshes importer fragments, paste bundles, and the generated
sections in `INSTALLATION.md` and `generated/BOOTSTRAP.md`. Only text between
`<!-- BEGIN GENERATED: name -->` and `<!-- END GENERATED: name -->` is replaced;
edit surrounding prose directly. Missing, duplicate, or reversed markers fail
rather than overwriting the document. Edit `src/importer.lua` instead of its
numbered helper fragments.

`make check` verifies generated output is current, every macro fits within 255
bytes, dependencies resolve, commands compile, and the Lua regression tests pass.
It does not rewrite files. `make test-tooling` exercises documentation preservation,
generator repeatability, and partial-staging behavior. CI runs both targets.
For Lua 5.1 or a different Python executable, use `make LUA=lua PYTHON=python3 check`.

The pre-commit hook exports **the staged snapshot** to a temporary directory and
runs `make check` there. This catches stale bundles or documentation in the commit,
even if the working tree already has newer output. The hook never rewrites or
stages files: on failure, run `make generate`, review and stage the matching changes,
then retry the commit. This keeps partially staged edits under your control.
`make install-hooks` sets this clone's local `core.hooksPath` to `.githooks`; hooks
are not enabled automatically in new clones. CI provides the same validation for
commits made without the local hook.

For a fresh in-game installation, run `{clear}`, `/reload`, manually recreate
`{import}`, and paste the current [install.lua](generated/install.lua). Click Import
and then `{cmds}`. Existing `fly` and `run` casing can be handled manually.

This project targets Retail WoW. The version-2 import flow has been reported
working in-game; version-3 icon updates still need in-game verification. The tests use mocked WoW APIs and do not prove protected-action,
combat, talent UI, or persistence behavior in a live client. Before relying on
restores, save a backup and check them on a test character; record the client
build from `GetBuildInfo()` when reporting results.

## Contributions

Feel free to contribute by submitting pull requests. Whether it's new macros, improvements to existing ones, or bug fixes, all contributions are welcome!

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
