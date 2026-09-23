-- Choose a usable mount for the current environment on every invocation.
if not wm.lib("outofcombat")() then return end
wm.lib("mount")()
