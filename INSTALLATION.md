# Installation

If replacing an older naming scheme, run its existing uninstall/reset macro before `/reload`
and reinstalling. The new `~1.uninstall` only removes the new reserved prefixes.

For GeForce Now and bulk installation, follow the [bootstrap guide](generated/BOOTSTRAP.md).
For this source-layout change, first run `~1.uninstall` outside combat
(or use the uninstall chat line in the bootstrap guide). It deletes all account
macros beginning with `~1.`, `~2.`, or `~3.`, including itself. Other account macros and
all character macros are preserved. Run `/reload`, then paste the line from
[bootstrap.lua](generated/bootstrap.lua) into WoW chat and press Enter. Paste
[install.lua](generated/install.lua) into the box it opens, press Enter, click Import,
and then click `~1.cmds`. No import macro needs to be created first.

All entries below are account macros delivered by the paste bundle. The table
links their source files for editing; never paste uncompiled sources into WoW.
The runtime concatenates chunks without separators before compiling each source.
Click `~1.cmds` after each login/reload to register slash commands. Core entry points can run before `~1.cmds`.

Imports match exact names only. No renames or migrations are performed. Remove old
standalone `fly`/`run` manually; use `/fly` and `/mount` instead.
Create optional action-bar shortcuts manually, using names without a system prefix.
For body-only updates, `/importmacros` accepts [macros.txt](generated/macros.txt).
Reset and reinstall when sources are added/removed or chunks become obsolete.

<!-- BEGIN GENERATED: icons -->
| Generated category | Managed icon |
| --- | --- |
| `core` | `inv_misc_punchcards_red` |
| `libs` | `inv_misc_punchcards_white` |
| `chunks` | `inv_misc_punchcards_yellow` |
<!-- END GENERATED: icons -->

Icons follow the generated category in [scripts/icons.json](scripts/icons.json).
Imports update managed icons even when bodies have not changed. The importer
never deletes macros; the generator rebuilds the bundle from current sources.

<!-- BEGIN GENERATED: inventory -->
| In-game name | Bytes | Source |
| --- | ---: | --- |
| `~2.load` | 167 | [src/libs/load.lua](src/libs/load.lua) |
| `~2.lout` | 255 | [src/libs/lout.lua](src/libs/lout.lua) |
| `~3.l002.002` | 46 | [src/libs/lout.lua](src/libs/lout.lua) |
| `~2.mount` | 255 | [src/libs/mount.lua](src/libs/mount.lua) |
| `~3.l003.002` | 184 | [src/libs/mount.lua](src/libs/mount.lua) |
| `~2.outofcombat` | 106 | [src/libs/outofcombat.lua](src/libs/outofcombat.lua) |
| `~2.save` | 202 | [src/libs/save.lua](src/libs/save.lua) |
| `~3.c001.001` | 255 | [src/cmds/accountbars.lua](src/cmds/accountbars.lua) |
| `~3.c001.002` | 255 | [src/cmds/accountbars.lua](src/cmds/accountbars.lua) |
| `~3.c001.003` | 255 | [src/cmds/accountbars.lua](src/cmds/accountbars.lua) |
| `~3.c001.004` | 75 | [src/cmds/accountbars.lua](src/cmds/accountbars.lua) |
| `~3.c002.001` | 144 | [src/cmds/clearloadouts.lua](src/cmds/clearloadouts.lua) |
| `~3.c003.001` | 37 | [src/cmds/clearmacros.lua](src/cmds/clearmacros.lua) |
| `~3.c004.001` | 196 | [src/cmds/clearquests.lua](src/cmds/clearquests.lua) |
| `~3.c005.001` | 36 | [src/cmds/cmds.lua](src/cmds/cmds.lua) |
| `~3.c006.001` | 51 | [src/cmds/fixres.lua](src/cmds/fixres.lua) |
| `~3.c007.001` | 51 | [src/cmds/fly.lua](src/cmds/fly.lua) |
| `~3.c008.001` | 255 | [src/cmds/importmacros.lua](src/cmds/importmacros.lua) |
| `~3.c008.002` | 255 | [src/cmds/importmacros.lua](src/cmds/importmacros.lua) |
| `~3.c008.003` | 255 | [src/cmds/importmacros.lua](src/cmds/importmacros.lua) |
| `~3.c008.004` | 255 | [src/cmds/importmacros.lua](src/cmds/importmacros.lua) |
| `~3.c008.005` | 255 | [src/cmds/importmacros.lua](src/cmds/importmacros.lua) |
| `~3.c008.006` | 255 | [src/cmds/importmacros.lua](src/cmds/importmacros.lua) |
| `~3.c008.007` | 255 | [src/cmds/importmacros.lua](src/cmds/importmacros.lua) |
| `~3.c008.008` | 255 | [src/cmds/importmacros.lua](src/cmds/importmacros.lua) |
| `~3.c008.009` | 255 | [src/cmds/importmacros.lua](src/cmds/importmacros.lua) |
| `~3.c008.010` | 255 | [src/cmds/importmacros.lua](src/cmds/importmacros.lua) |
| `~3.c008.011` | 255 | [src/cmds/importmacros.lua](src/cmds/importmacros.lua) |
| `~3.c008.012` | 255 | [src/cmds/importmacros.lua](src/cmds/importmacros.lua) |
| `~3.c008.013` | 255 | [src/cmds/importmacros.lua](src/cmds/importmacros.lua) |
| `~3.c008.014` | 255 | [src/cmds/importmacros.lua](src/cmds/importmacros.lua) |
| `~3.c008.015` | 255 | [src/cmds/importmacros.lua](src/cmds/importmacros.lua) |
| `~3.c008.016` | 255 | [src/cmds/importmacros.lua](src/cmds/importmacros.lua) |
| `~3.c008.017` | 255 | [src/cmds/importmacros.lua](src/cmds/importmacros.lua) |
| `~3.c008.018` | 255 | [src/cmds/importmacros.lua](src/cmds/importmacros.lua) |
| `~3.c008.019` | 147 | [src/cmds/importmacros.lua](src/cmds/importmacros.lua) |
| `~3.c009.001` | 255 | [src/cmds/loadbars.lua](src/cmds/loadbars.lua) |
| `~3.c009.002` | 255 | [src/cmds/loadbars.lua](src/cmds/loadbars.lua) |
| `~3.c009.003` | 255 | [src/cmds/loadbars.lua](src/cmds/loadbars.lua) |
| `~3.c009.004` | 115 | [src/cmds/loadbars.lua](src/cmds/loadbars.lua) |
| `~3.c010.001` | 183 | [src/cmds/loadloadouts.lua](src/cmds/loadloadouts.lua) |
| `~3.c011.001` | 255 | [src/cmds/loadmacros.lua](src/cmds/loadmacros.lua) |
| `~3.c011.002` | 255 | [src/cmds/loadmacros.lua](src/cmds/loadmacros.lua) |
| `~3.c011.003` | 255 | [src/cmds/loadmacros.lua](src/cmds/loadmacros.lua) |
| `~3.c011.004` | 126 | [src/cmds/loadmacros.lua](src/cmds/loadmacros.lua) |
| `~3.c012.001` | 255 | [src/cmds/macroicon.lua](src/cmds/macroicon.lua) |
| `~3.c012.002` | 50 | [src/cmds/macroicon.lua](src/cmds/macroicon.lua) |
| `~3.c013.001` | 34 | [src/cmds/mount.lua](src/cmds/mount.lua) |
| `~3.c014.001` | 255 | [src/cmds/savebars.lua](src/cmds/savebars.lua) |
| `~3.c014.002` | 67 | [src/cmds/savebars.lua](src/cmds/savebars.lua) |
| `~3.c015.001` | 132 | [src/cmds/saveloadout.lua](src/cmds/saveloadout.lua) |
| `~3.c016.001` | 244 | [src/cmds/savemacros.lua](src/cmds/savemacros.lua) |
| `~3.c017.001` | 255 | [src/cmds/way.lua](src/cmds/way.lua) |
| `~3.c017.002` | 158 | [src/cmds/way.lua](src/cmds/way.lua) |
| `~3.k001.001` | 255 | [src/core/cmds.lua](src/core/cmds.lua) |
| `~3.k001.002` | 255 | [src/core/cmds.lua](src/core/cmds.lua) |
| `~3.k001.003` | 255 | [src/core/cmds.lua](src/core/cmds.lua) |
| `~3.k001.004` | 255 | [src/core/cmds.lua](src/core/cmds.lua) |
| `~3.k001.005` | 255 | [src/core/cmds.lua](src/core/cmds.lua) |
| `~3.k001.006` | 255 | [src/core/cmds.lua](src/core/cmds.lua) |
| `~3.k001.007` | 255 | [src/core/cmds.lua](src/core/cmds.lua) |
| `~3.k001.008` | 40 | [src/core/cmds.lua](src/core/cmds.lua) |
| `~1.cmds` | 143 | [src/core/cmds.lua](src/core/cmds.lua) |
| `~1.uninstall` | 251 | [src/core/uninstall.lua](src/core/uninstall.lua) |

64/120 account slots; 24 source files. Every stored macro fits within 255 bytes (largest: 255).
<!-- END GENERATED: inventory -->

The importer targets Retail WoW. The generic compiler/runtime passes mocked API
tests; the current generated bundle still needs an in-game check.
