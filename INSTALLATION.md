# Installation

For GeForce Now and bulk updates, follow the [bootstrap guide](generated/BOOTSTRAP.md).
To reset first, manually create `{clear}` from [clear.lua](macros/core/clear.lua)
and run it outside combat. It deletes all general macros beginning with `{`, `[`, or `|`,
including itself. Other general macros and all character macros are preserved.
Run `/reload`, then create `{import}` from [import.lua](macros/core/import.lua).
Click it, paste [install.lua](generated/install.lua), press Enter, and click Import.
Then click `{cmds}`. Later updates use `/importmacros` with [macros.txt](generated/macros.txt).

All entries are general/account macros. Names use lowercase, braces, and square brackets. Imports match exact names only.
Commands also require `{cmds}` and `{[run]}`. The table lists direct dependencies.
Core names use `{name}`, shared libraries `{[name]}`, commands `[name]`,
and command helpers `[[name]]`. No names contain pipes. No renames or migrations are performed.
Byte counts include all newlines. Do not add `/run` to raw Lua libraries or command bodies.

<!-- BEGIN GENERATED: icons -->
| Directory | Managed icon |
| --- | --- |
| `macros/core/` | `inv_misc_punchcards_red` |
| `macros/core/libs/` | `inv_misc_punchcards_white` |
| `macros/cmds/` | `inv_misc_punchcards_blue` |
| `macros/cmds/libs/` | `inv_misc_punchcards_yellow` |
<!-- END GENERATED: icons -->

The most specific directory wins. Existing icons in other directories are preserved;
new macros in those directories use the question-mark icon. Imports update managed icons
even when macro bodies have not changed. No macros are deleted by the importer.

<!-- BEGIN GENERATED: inventory -->
| In-game name | File | Bytes | Direct dependencies, in order |
| --- | --- | ---: | --- |
| `{clear}` | [macros/core/clear.lua](macros/core/clear.lua) | 232 | — |
| `{cmds}` | [macros/core/cmds.lua](macros/core/cmds.lua) | 252 | `{[run]}` |
| `fly` | [macros/common/fly.lua](macros/common/fly.lua) | 216 | `{[mount]}` |
| `run` | [macros/common/run.lua](macros/common/run.lua) | 199 | `{[mount]}` |
| `{[run]}` | [macros/core/libs/run.lua](macros/core/libs/run.lua) | 180 | — |
| `{[mount]}` | [macros/core/libs/mount.lua](macros/core/libs/mount.lua) | 234 | — |
| `{[save]}` | [macros/core/libs/save.lua](macros/core/libs/save.lua) | 182 | — |
| `{[load]}` | [macros/core/libs/load.lua](macros/core/libs/load.lua) | 172 | — |
| `{[lout]}` | [macros/core/libs/lout.lua](macros/core/libs/lout.lua) | 254 | — |
| `[accountbars]` | [macros/cmds/accountbars.lua](macros/cmds/accountbars.lua) | 90 | `[[accountbars1]]`, `[[accountbars2]]`, `[[accountbars3]]`, `[[accountbars4]]` |
| `[clearloadouts]` | [macros/cmds/clearloadouts.lua](macros/cmds/clearloadouts.lua) | 118 | `{[lout]}` |
| `[clearmacros]` | [macros/cmds/clearmacros.lua](macros/cmds/clearmacros.lua) | 56 | — |
| `[clearquests]` | [macros/cmds/clearquests.lua](macros/cmds/clearquests.lua) | 200 | — |
| `[fixres]` | [macros/cmds/fixres.lua](macros/cmds/fixres.lua) | 65 | — |
| `[loadbars]` | [macros/cmds/loadbars.lua](macros/cmds/loadbars.lua) | 214 | `{[load]}`, `{[lout]}`, `[[outofcombat]]`, `[[loadbars1]]`, `[[loadbars2]]`, `[[loadbars3]]` |
| `[loadloadouts]` | [macros/cmds/loadloadouts.lua](macros/cmds/loadloadouts.lua) | 160 | `{[load]}`, `{[lout]}` |
| `[loadmacros]` | [macros/cmds/loadmacros.lua](macros/cmds/loadmacros.lua) | 185 | `{[load]}`, `{[lout]}`, `[[outofcombat]]`, `[[loadmacros1]]`, `[[macrocheck]]`, `[[loadmacros2]]` |
| `[macroicon]` | [macros/cmds/macroicon.lua](macros/cmds/macroicon.lua) | 99 | `[[outofcombat]]`, `[[macroicon]]` |
| `[savebars]` | [macros/cmds/savebars.lua](macros/cmds/savebars.lua) | 126 | `{[save]}`, `{[lout]}`, `[[savebars]]` |
| `[saveloadout]` | [macros/cmds/saveloadout.lua](macros/cmds/saveloadout.lua) | 123 | `{[save]}`, `{[lout]}` |
| `[savemacros]` | [macros/cmds/savemacros.lua](macros/cmds/savemacros.lua) | 195 | `{[save]}`, `{[lout]}` |
| `[way]` | [macros/cmds/way.lua](macros/cmds/way.lua) | 116 | `[[way1]]`, `[[way2]]` |
| `[[accountbars1]]` | [macros/cmds/libs/accountbars1.lua](macros/cmds/libs/accountbars1.lua) | 106 | — |
| `[[accountbars2]]` | [macros/cmds/libs/accountbars2.lua](macros/cmds/libs/accountbars2.lua) | 176 | — |
| `[[accountbars3]]` | [macros/cmds/libs/accountbars3.lua](macros/cmds/libs/accountbars3.lua) | 227 | — |
| `[[accountbars4]]` | [macros/cmds/libs/accountbars4.lua](macros/cmds/libs/accountbars4.lua) | 205 | — |
| `[[outofcombat]]` | [macros/cmds/libs/outofcombat.lua](macros/cmds/libs/outofcombat.lua) | 70 | — |
| `[[savebars]]` | [macros/cmds/libs/savebars.lua](macros/cmds/libs/savebars.lua) | 158 | — |
| `[[loadbars1]]` | [macros/cmds/libs/loadbars1.lua](macros/cmds/libs/loadbars1.lua) | 228 | — |
| `[[loadbars2]]` | [macros/cmds/libs/loadbars2.lua](macros/cmds/libs/loadbars2.lua) | 136 | — |
| `[[loadbars3]]` | [macros/cmds/libs/loadbars3.lua](macros/cmds/libs/loadbars3.lua) | 192 | — |
| `[[loadmacros1]]` | [macros/cmds/libs/loadmacros1.lua](macros/cmds/libs/loadmacros1.lua) | 209 | — |
| `[[macrocheck]]` | [macros/cmds/libs/macrocheck.lua](macros/cmds/libs/macrocheck.lua) | 227 | — |
| `[[loadmacros2]]` | [macros/cmds/libs/loadmacros2.lua](macros/cmds/libs/loadmacros2.lua) | 174 | — |
| `[[way1]]` | [macros/cmds/libs/way1.lua](macros/cmds/libs/way1.lua) | 244 | — |
| `[[way2]]` | [macros/cmds/libs/way2.lua](macros/cmds/libs/way2.lua) | 84 | — |
| `[[macroicon]]` | [macros/cmds/libs/macroicon.lua](macros/cmds/libs/macroicon.lua) | 194 | — |
| `{import}` | [macros/core/import.lua](macros/core/import.lua) | 242 | — |
| `[importmacros]` | [macros/cmds/importmacros.lua](macros/cmds/importmacros.lua) | 194 | `[[im01]]`, `[[im02]]`, `[[im03]]`, `[[im04]]`, `[[im05]]`, `[[im06]]`, `[[im07]]`, `[[im08]]`, `[[im09]]`, `[[im10]]`, `[[im11]]`, `[[im12]]`, `[[im13]]`, `[[im14]]`, `[[im15]]`, `[[im16]]`, `[[im17]]`, `[[im18]]`, `[[im19]]` |
| `[[im01]]` | [macros/cmds/libs/im01.lua](macros/cmds/libs/im01.lua) | 224 | — |
| `[[im02]]` | [macros/cmds/libs/im02.lua](macros/cmds/libs/im02.lua) | 204 | — |
| `[[im03]]` | [macros/cmds/libs/im03.lua](macros/cmds/libs/im03.lua) | 233 | — |
| `[[im04]]` | [macros/cmds/libs/im04.lua](macros/cmds/libs/im04.lua) | 254 | — |
| `[[im05]]` | [macros/cmds/libs/im05.lua](macros/cmds/libs/im05.lua) | 246 | — |
| `[[im06]]` | [macros/cmds/libs/im06.lua](macros/cmds/libs/im06.lua) | 238 | — |
| `[[im07]]` | [macros/cmds/libs/im07.lua](macros/cmds/libs/im07.lua) | 245 | — |
| `[[im08]]` | [macros/cmds/libs/im08.lua](macros/cmds/libs/im08.lua) | 188 | — |
| `[[im09]]` | [macros/cmds/libs/im09.lua](macros/cmds/libs/im09.lua) | 195 | — |
| `[[im10]]` | [macros/cmds/libs/im10.lua](macros/cmds/libs/im10.lua) | 222 | — |
| `[[im11]]` | [macros/cmds/libs/im11.lua](macros/cmds/libs/im11.lua) | 199 | — |
| `[[im12]]` | [macros/cmds/libs/im12.lua](macros/cmds/libs/im12.lua) | 240 | — |
| `[[im13]]` | [macros/cmds/libs/im13.lua](macros/cmds/libs/im13.lua) | 246 | — |
| `[[im14]]` | [macros/cmds/libs/im14.lua](macros/cmds/libs/im14.lua) | 246 | — |
| `[[im15]]` | [macros/cmds/libs/im15.lua](macros/cmds/libs/im15.lua) | 226 | — |
| `[[im16]]` | [macros/cmds/libs/im16.lua](macros/cmds/libs/im16.lua) | 240 | — |
| `[[im17]]` | [macros/cmds/libs/im17.lua](macros/cmds/libs/im17.lua) | 115 | — |
| `[[im18]]` | [macros/cmds/libs/im18.lua](macros/cmds/libs/im18.lua) | 239 | — |
| `[[im19]]` | [macros/cmds/libs/im19.lua](macros/cmds/libs/im19.lua) | 158 | — |

All 58 files fit within 255 bytes; the largest is 254 bytes.
<!-- END GENERATED: inventory -->

The importer targets Retail WoW. Its version-2 bootstrap and import flow were
reported working in-game; version-3 icon updates still need in-game verification.
