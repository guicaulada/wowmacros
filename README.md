# World of Warcraft Macros Collection

Welcome to my World of Warcraft macros repository! This project is organized to help manage and utilize various macros efficiently. The macros are organized into different folders based on their function, and naming conventions are used to control their order for easy access and management within the game.

## Project Structure

```plaintext
macros/
├── cmds/
│   └── libs/
├── libs/
```

### Explanation

- **macros/**: The main directory containing all macros.
  - **cmds/**: Folder for macros using the `#cmd` mechanic.
    - **libs/**: Subfolder within `cmds` for additional libraries or files executed by the commands.
  - **libs/**: Main libraries folder.
  - All other macros.

### Naming Conventions

The naming conventions provided are recommendations for how the macros should be named within the game, not necessarily how the files are named within the project folders. This allows for better organization and access when you are managing your macros in-game.

- **Engine Macros**: Should be named using `{<name>}` within the game to ensure they appear just before the main libraries and after all other macros.
- **Main Libraries**: Use `{|<name>|}` for main libraries, so they appear right after the engine macros.
- **Command Macros**: Should be named using `|<name>|` to keep them second to last.
- **Supporting Libraries**: Name these with `||<name>||` to ensure they are listed last.
- **Other Macros**: Can be named freely, especially if they are simpler macros like "fly" or "run".

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
#cmd myCommand
/run print("This is my custom command!")
#run macro1 macro2 macro3
```

In this example:

- The `#cmd myCommand` will create a command named `myCommand`.
- The `#run macro1 macro2 macro3` will inject the contents of `macro1`, `macro2`, and `macro3` into this command's execution, in that order.

## How to Use

1. Clone this repository to your local machine.
2. Browse through the `macros` folder and its subdirectories to find the macros or libraries you need.
3. Customize the macros as needed by editing the relevant files.
4. Copy the macros to the **general macros** section in World of Warcraft, not the character-specific macros section, to ensure they are available across all characters.

## Contributions

Feel free to contribute by submitting pull requests. Whether it's new macros, improvements to existing ones, or bug fixes, all contributions are welcome!

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
