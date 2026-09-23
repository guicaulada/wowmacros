# World of Warcraft Macros

An addon-free macro system for Retail WoW, including GeForce Now. Write each
command or library as one readable Lua file. The compiler removes comments and
unnecessary whitespace, then splits the code into stored macros of at most
**255 bytes**. The runtime reassembles each source before executing it.

## Get started

Follow the [bootstrap guide](docs/BOOTSTRAP.md): paste the chat line, paste the
installer into its box, click **Import**, then click `~1.cmds`. No manual macro
creation or access to WoW's filesystem is needed.

Click `~1.cmds` after each login/reload. Run `/cmds` to list installed commands.
For an action-bar shortcut, create your own macro containing a command such as
`/mount`.

## Documentation

- [Installation, updates, and uninstalling](docs/BOOTSTRAP.md)
- [Command reference](docs/COMMANDS.md)
- [Generated macro inventory and icons](docs/INSTALLATION.md)
- [Source layout, authoring, generation, and validation](docs/DEVELOPMENT.md)

Edit `src/core`, `src/cmds`, and `src/libs`, then run:

```sh
make generate
make check test-tooling
```

Enable staged validation once per clone with `make install-hooks`.
The paste-ready artifacts stay in `generated/`. Documentation lives in `docs/`;
marked code blocks and inventory tables are refreshed by `make generate`.

The current compiler/runtime passes mocked API tests and still needs an in-game
check. Tests cannot establish live protected-action or persistence behavior.

## License

[MIT](LICENSE).
