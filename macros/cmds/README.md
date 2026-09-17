# Commands

This directory contains macros that define various commands you can use in World of Warcraft. Each command is designed to perform specific tasks that can enhance your gameplay. Below is a description of each command available in this directory:

**Note:** All command macros are dependent on the `cmds` engine macro and the `run` library to function correctly. Ensure that they are properly set up and available. Execute the `cmds` macro once per session to make the commands available in-game.

### 1. `/accountbars`
Sets up action bars with abilities that are the same for all your characters, such as hearthstones, mounts, utilities, and profession abilities. This command helps standardize certain abilities across multiple characters.

### 2. `/clearloadouts`
Deletes all the talent loadouts saved on your character. Use this command when you want to clear out old or unused loadouts.

### 3. `/clearmacros`
Deletes all the character-specific macros of the current character. This is useful for cleaning up or resetting macros for a specific character.

### 4. `/clearquests`
Deletes all quests except campaign quests. This command can help you quickly clear your quest log of non-essential quests.

### 5. `/loadloadouts`
Loads all the saved loadouts for the current spec. Use this command to quickly apply previously saved loadouts, ensuring consistency across your characters of the same class and spec.

### 6. `/loadmacros`
Replaces all character-specific macros with the saved snapshot for the current class, in saved slot order. General macros are untouched. Repeating the command does not create duplicates. A missing snapshot does nothing; an empty snapshot clears character macros. Snapshot shape, body lengths, and capacity are checked before deletion. Run outside combat and restore action bars afterward. If a creation API call fails, restoration stops with a message; it is not transactional.

### 7. `/macroicon <macro_name> <icon_name>`
Accepts an existing macro name (including spaces) followed by an icon name or positive numeric file ID. Invalid syntax or an unknown macro prints usage. Run outside combat. Texture names are passed through to the game; their existence is not checked. Allows you to set the icon using an icon name from [Wowhead](https://www.wowhead.com/icons). This command makes it easy to customize macro icons for better visual organization.

### 8. `/saveloadout`
Saves the current loadout to be loaded by `/loadloadouts` on other characters of the same class and spec. This command helps you maintain consistency across different characters.

### 9. `/savemacros`
Replaces the saved class snapshot with the current character macros. Macros removed since the previous save are removed from storage too. An empty character macro list saves an empty snapshot.

### 10. `/way <x> <y>`
Accepts coordinates from 0 to 100, separated by spaces or a comma, and validates the current map before setting a waypoint. Invalid input prints usage without changing the waypoint. Creates a waypoint, similar to how TomTom works. Note that the game only allows one waypoint at a time, and you must be on the correct map for the coordinates to work correctly. This command is helpful for navigating to specific locations.

### 11. `/savebars`
Saves a complete snapshot of slots 1–240 for the selected saved loadout. Select a named loadout first. Macro actions are stored by name. Later saves replace the snapshot, including slots that became empty. This is useful for maintaining consistent action bar setups across multiple characters.

### 12. `/loadbars`
Restores slots 1–240 for the selected saved loadout, including clearing slots that were empty when saved. Supports spells, macros by name, and items. Unsupported types (such as flyouts, equipment sets, and battle pets) or unavailable actions abort the entire restore during preflight, leaving the existing bars unchanged. Run outside combat. Load macros first and use unique macro names across general and character macros. If an action becomes unavailable after preflight, restoration stops with a message; earlier changes are not rolled back.

### 13. `/fixres`
Resets the resolution to the graphics menu's **Default** option (automatic sizing) and applies it immediately. Intended for **Windowed (Fullscreen)** mode, where WoW offers the Default option.

Copy `fixres.lua` into a general macro named `[fixres]`, then execute the `cmds` engine macro to register `/fixres`. Register it again after each login or reload.

See the [installation table](../../INSTALLATION.md) for all required helper macros.

### 14. `/importmacros`
Opens the multiline import window. Paste the complete [generated bundle](../../generated/macros.txt)
and click Import outside combat. Existing account macros are updated by exact,
exact stored name. Duplicate exact matches are rejected; missing macros are
created. No names are changed or migrated. Icons follow the directory policy
in `scripts/icons.json`, including updates to existing macros.
Character macros and unrelated account macros are untouched. Duplicate names,
malformed/truncated bundles, oversized bodies, or insufficient slots abort before
any writes. API failures during writing stop the import and leave earlier changes
in place. Click `{cmds}` afterward to register changed commands.

The [bootstrap guide](../../generated/BOOTSTRAP.md) installs this command and all
its helpers with one manually created macro. The importer implementation lives
in `src/importer.lua`; its `IM` helper files are generated.
