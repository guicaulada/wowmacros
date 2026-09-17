if not nh then return bad("expected hex name:icon:body; paste the latest bundle.") end
if #nh%2~=0 or #ih%2~=0 or #h%2~=0 then return bad("incomplete hex data.") end
if #nh>32 then return bad("name exceeds 16 bytes.") end
