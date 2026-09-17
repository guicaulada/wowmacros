# Command Libraries

These are raw Lua fragments stored in separate general macros to keep each macro
within 255 bytes. The command engine joins them with `#run`; some fragments share
local variables and must be included in the documented order. They are not
standalone slash commands.

See the [installation table](../../../INSTALLATION.md) for exact in-game names,
byte counts, and each command's dependencies.

- `accountbars1`–`accountbars4`: the existing personal account-bar layout.
- `outofcombat`: rejects changes during combat.
- `savebars`: collects the complete action-bar snapshot and saves it once.
- `loadbars1`–`loadbars3`: supported pickups, preflight, and slot restoration.
- `loadmacros1`, `macrocheck`, `loadmacros2`: snapshot ordering/capacity, entry
  validation, and replacement of character macros.
- `way1`–`way2`: coordinate/map validation and waypoint placement.
- `macroicon`: argument validation and icon editing.
- `im01` and subsequent numbered helpers: generated importer UI, bundle parsing,
  validation, and account macro updates. Edit `src/importer.lua` and regenerate
  with `python3 scripts/build-importer.py`; do not edit the fragments directly.
