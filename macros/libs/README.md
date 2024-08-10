# Main Libraries

This directory contains essential libraries that support various macros within the overall framework. Below is a description of each file included in this directory:

### 1. `run`
The `run` file enables the usage of the `#run` mechanic. This mechanic allows you to inject the code of other macros into your current macro's scope, enabling modular macro creation. You can chain multiple macros together by using `#run macro1 macro2 macro3`.

**Note:** The `run` macro is already injected by the `cmds` macro, so you don't need to call it explicitly.

### 2. `save`
The `save` file provides the `_S(value, keys...)` function, which allows you to save values between sessions and characters using the `Blizzard_Console_SavedVars` variable. This functionality is useful for persisting data, such as configurations or loadouts, across gaming sessions.

To use the `save` functionality, you need to add `#run {|save|}` to your macro before calling the `_S` function.

**Example Usage:**

```plaintext
#run {|save|}
_S(loadoutString, "sl", specID, loadoutName)
```

In this example, `loadoutString` is saved under a unique key combination of `"sl"`, `specID`, and `loadoutName`.

### 3. `load`
The `load` file provides the `_L(keys...)` function, which allows you to load values previously saved in the `Blizzard_Console_SavedVars` variable. This functionality is essential for retrieving persistent data stored by the `_S` function.

To use the `load` functionality, you need to add `#run {|load|}` to your macro before calling the `_L` function.

**Example Usage:**

```plaintext
#run {|load|}
local loadoutString = _L("sl", specID, loadoutName)
```

In this example, the function returns the `loadoutString` that was saved with the specified keys.

### 4. `lout`
The `lout` library introduces the `_LO` variable, which is used to retrieve detailed loadout information for your character. This can be particularly useful for macros that need to adapt or respond to your character's current loadout.

#### Available Properties:
- **`_LO.class`**: Retrieves the class name of the character.
- **`_LO.spec`**: Retrieves the spec ID of the current specialization.
- **`_LO.name`**: Retrieves the name of the current loadout.
- **`_LO.configs`**: Retrieves all configuration IDs associated with the current specialization.
