# Macro collection

- [core](core/): `{cmds}` registers slash commands; `{import}` bootstraps the importer; `{clear}` resets prefixed account macros.
- [common](common/): `fly` and `run` are click/shortcut macros for summoning mounts.
- [cmds](cmds/): slash commands, including `/importmacros`.
- [cmds/libs](cmds/libs/): raw Lua fragments supporting commands.
- [core/libs](core/libs/): shared libraries for command expansion, persistence, loadouts, and mounts.

Names use lowercase. Core macros use red punchcard icons, shared core libraries
white, commands blue, and command helpers yellow.
The [installation table](../INSTALLATION.md) contains exact names and dependencies.
Use the [bootstrap guide](../generated/BOOTSTRAP.md) to install without an addon.
