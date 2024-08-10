# Main Macros

This folder contains various macros designed to enhance your World of Warcraft gameplay. Below is a description of each macro included in this directory:

### 1. `cmds`
The `cmds` macro is an engine macro responsible for processing any macro that begins with `#cmd <command>`. It converts these macros into usable in-game commands. This macro should be called once per session, typically on reload or login, to initialize the command framework.

**Dependency:** The `cmds` macro is dependent on the `libs/run` macro to function correctly. Ensure that the `run` macro is properly set up and available.

### 2. `fly`
The `fly` macro is used to summon a random flying mount from your collection. The goal is to allow you to use all the flying mounts you own, even those you may have forgotten about, adding variety to your flying experiences.

### 3. `run`
The `run` macro summons a random ground mount from your collection. Similar to the `fly` macro, it ensures you can enjoy all your ground mounts, bringing some variety to your ground travel by using mounts you might not remember you have.
