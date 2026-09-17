# Core macros

- `{cmds}`: run after login/reload and command changes to register slash commands.
  Requires `{[run]}` and all dependencies of installed commands.
- `{import}`: opens the one-time installer paste box. Paste the generated
  [install.lua](../../generated/install.lua), press Enter, then click Import.
  Subsequent updates use `/importmacros` and the data-only bundle.
- `{clear}`: standalone reset. Outside combat, deletes all general/account macros
  whose names start with `{`, `[`, or `|`, including itself. Walks backward through the
  account slots so deletion does not skip entries. No command engine or library
  is required. Preserves other general macros and all character macros.

All three use `inv_misc_punchcards_red` after import. Shared libraries live in
[libs](libs/) and use `inv_misc_punchcards_white`. To start over, manually create
and run `{clear}`, run `/reload`, then manually create `{import}` and follow the
[bootstrap guide](../../generated/BOOTSTRAP.md). No old bootstrap is assumed to exist
or renamed. The fresh import recreates `{clear}` along with the rest of the system.
