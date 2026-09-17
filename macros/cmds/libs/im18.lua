if not j or GetMacroInfo(j)~=n or select(3,GetMacroInfo(j))~=v or (icon and select(2,GetMacroInfo(j))~=icon) then return fail("could not write "..n.."; earlier changes remain.") end
if i then changed=changed+1 else made=made+1 end
end
end
