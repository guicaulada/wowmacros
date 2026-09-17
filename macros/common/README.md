# Common click/shortcut macros

- `fly`: selects a random collected flying mount of type 424, 248, or 402.
- `run`: selects a random collected type-230 ground mount, excluding the active mount.

Both scan the collection once and report when no mount matches. They require
`{[mount]}` but not the command engine. Current usability is not checked. Existing
icons are preserved by imports. These are ordinary clickable macros, unlike the
slash-command definitions in `cmds/`.
