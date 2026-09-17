# Commands

Each `.lua` file is a complete command body. The generator supplies only its code chunks;
clickable shortcuts can be created manually. Install the full bundle and click `~1.cmds` after every login/reload.
Do not paste these source files directly into WoW.

| Command | Behavior |
| --- | --- |
| `/accountbars` | Apply the shared action-bar layout, including utilities and professions; mount shortcut slots are left untouched. |
| `/clearloadouts` | Delete the current specialization's talent configurations and activate the starter build. |
| `/clearmacros` | Delete all character macros, preserving account macros. |
| `/cmds` | List all slash commands installed by this system, alphabetically and separated by spaces. |
| `/clearquests` | Abandon non-campaign quests. |
| `/fixres` | Apply automatic window sizing, intended for Windowed (Fullscreen). |
| `/fly` | Summon a random collected mount matching the configured flying mount types. |
| `/mount` | Summon a random collected ground mount, excluding the active mount. |
| `/importmacros` | Open the bundle importer; update exact account names or create missing entries. |
| `/loadbars` | Restore the selected saved loadout's action bars. |
| `/loadloadouts` | Import saved talent strings for the current specialization through the talents UI. |
| `/loadmacros` | Replace character macros with the saved class snapshot. |
| `/macroicon <name> <icon>` | Change an existing macro's icon; names may contain spaces and icons may be names or positive file IDs. |
| `/savebars` | Replace the selected loadout's action-bar snapshot. |
| `/saveloadout` | Save the current talents UI export under specialization and loadout name. |
| `/savemacros` | Replace the class's character-macro snapshot. |
| `/way <x> <y>` | Set a waypoint using percentages from 0–100, separated by spaces or a comma. |

`/loadmacros` validates snapshot shape, body sizes, and capacity before deletion.
A missing snapshot leaves macros alone; an empty snapshot clears them. Restores
use saved slot order and do not accumulate duplicates. API failures stop the
restore, leaving earlier changes in place.

`/savebars` and `/loadbars` cover slots 1–240, including empty slots. Macro actions
are saved by name; use unique macro names across account and character macros.
The restore supports spells, macros, and items. Unsupported or unavailable actions
abort during preflight without changing bars. If an action becomes unavailable
after preflight, the restore stops without rolling earlier changes back.
Restore macros before bars that reference them. Both restores require being out
of combat. Select a named saved loadout before saving or restoring bars.

The importer validates the complete bundle before writing. It preserves unrelated
account macros and character macros, and does not rename or delete existing macros.
Follow the [bootstrap guide](../../generated/BOOTSTRAP.md) for a fresh installation
or [authoring instructions](../../README.md#writing-a-command) to add a command.
