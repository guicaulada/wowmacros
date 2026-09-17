-- Character macros occupy slots 121–138; account macros hold the system and remain intact.
for i = 138, 121, -1 do
    DeleteMacro(i)
end
