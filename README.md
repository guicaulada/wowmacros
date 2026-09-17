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

## Validation

Run from the repository root with LuaJIT or Lua 5.1:

```sh
python3 scripts/build-importer.py --check
luajit tests/validate.lua
luajit tests/importer.lua
```

The validator checks every macro's byte count (including directives and all
newlines), exact names, manifest coverage, dependencies, expanded command syntax,
engine registration, and mocked behavior for the fixed commands. It runs in CI.
Add new files to [scripts/manifest.lua](scripts/manifest.lua), then regenerate the
installation table and bundles. Keep individually stored files at or below 255 bytes; expanded command
functions can be larger because they are compiled at runtime.

To reset before importing, manually create a general macro named `{clear}` from
[macros/core/clear.lua](macros/core/clear.lua) and run it outside combat. It deletes
**every general macro whose name starts with `{`, `[`, or `|`**, including itself, core
macros, commands, and libraries. Other general macros (such as `fly` and `run`) and
all character macros are preserved. Run `/reload` to discard old command handlers,
then manually create `{import}` from [macros/core/import.lua](macros/core/import.lua)
and follow the [bootstrap guide](generated/BOOTSTRAP.md). The importer recreates
`{clear}` with the red punchcard icon. This workflow requires no existing helpers.

For this naming change, run `{clear}`, run `/reload`, manually recreate `{import}`,
and paste the latest [install.lua](generated/install.lua). Click Import and then
`{cmds}`. The bootstrap does not depend on any installed helper macros.

After editing any macro or the icon policy, regenerate the paste bundles and
installation table:

```sh
python3 scripts/build-importer.py
```

Edit [src/importer.lua](src/importer.lua) to change the importer. The generator
packs it into `[[im01]]` and subsequent helpers without exceeding 255 bytes per
file, updates its manifest entries, and regenerates both paste bundles. Do not
edit these generated helpers directly. The bootstrap includes the current full
bundle; normal updates only need `generated/macros.txt`. If importer code itself
changes, `/reload` and click `{cmds}` after importing to use the new implementation.

This project targets Retail WoW. The version-2 import flow has been reported
working in-game; version-3 icon updates still need in-game verification. The tests use mocked WoW APIs and do not prove protected-action,
combat, talent UI, or persistence behavior in a live client. Before relying on
restores, save a backup and check them on a test character; record the client
build from `GetBuildInfo()` when reporting results.

## Contributions

Feel free to contribute by submitting pull requests. Whether it's new macros, improvements to existing ones, or bug fixes, all contributions are welcome!

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
