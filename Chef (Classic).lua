memory.usememorydomain("EWRAM")
local m = {[0]=0x03C62A,[1]=0x03C6A6,[2]=0x03C722,[3]=0x03C79E}
while true do
	for i = 0, 3 do 
		if (memory.readbyte(m[i]) == 0) then
			local p = memory.readbyte(0x03C1D8)
			if (i == 0) and (p == 1) then
				joypad.set({Left = 1})
			elseif (i == 0) and (p == 2) then
				joypad.set({B = 1})
			elseif (i == 0) and (p == 3) then
				joypad.set({Left = 1})
			elseif (i == 1) and (p == 0) then
				joypad.set({Right = 1})
			elseif (i == 1) and (p == 2) then
				joypad.set({B = 1})
			elseif (i == 1) and (p == 3) then
				joypad.set({Left = 1})
			elseif (i == 2) and (p == 0) then
				joypad.set({Right = 1})
			elseif (i == 2) and (p == 1) then
				joypad.set({A = 1})
			elseif (i == 2) and (p == 3) then
				joypad.set({Left = 1})
			elseif (i == 3) and (p == 0) then
				joypad.set({Right = 1})
			elseif (i == 3) and (p == 1) then
				joypad.set({A = 1})
			elseif (i == 3) and (p == 2) then
				joypad.set({Right = 1})
			end
		end
	end
	emu.frameadvance()
end