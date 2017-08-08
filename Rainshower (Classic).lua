memory.usememorydomain("Combined WRAM")
while true do
	local tears = {}
	local shirts = {[1]=0x03C1E8,[2]=0x03C1E9,[3]=0x03C1EA,[4]=0x03C1EB} --shirts state
	if memory.readbyte(0x0414A4) > 0 and memory.readbyte(0x0414A0) == 4 then
		if memory.readbyte(0x0414A8) == 0  then
			tears = {[1]=0x03ABBA,[2]=0x03AB3E,[3]=0x03AC36,[4]=0x03ACB2}	-- first 2 tears y position address in game A; game B replaced by crows
			gui.drawText(3,3,"EASY",'RED')
		else
			tears = {[1]=0x03AD2E,[2]=0x03ADAA,[3]=0x03AC36,[4]=0x03ACB2}
			gui.drawText(3,3,"Hard",'RED')
		end
		for i = 1, 4 do 
		gui.drawText(3,i*10,"tears:"..memory.readbyte(tears[i]+14),'RED')
				local p = memory.readbyte(0x03C1E4) -- your position
				if (memory.readbyte(shirts[1]) == 0) and (memory.readbyte(tears[i]+14) == 52 or memory.readbyte(tears[i]+14) == 108) and (memory.readbyte(tears[i]) == 3) then
					if (p == 1) then
						joypad.set({Left = 1})
						emu.frameadvance()
						joypad.set({A = 1})
					elseif (p == 2) then 
						joypad.set({Up = 1})
						emu.frameadvance()
						joypad.set({A = 1})
					elseif (p == 3) then 
						joypad.set({Left = 1,Up = 1})
						emu.frameadvance()
						joypad.set({A = 1})
					else 
						joypad.set({A = 1})
					end
				elseif (memory.readbyte(shirts[1]) == 1) and (memory.readbyte(tears[i]+14) == 80 or memory.readbyte(tears[i]+14) == 136) and (memory.readbyte(tears[i]) == 3) then
					if (p == 1) then
						joypad.set({Left = 1})
						emu.frameadvance()
						joypad.set({A = 1})
				elseif (p == 2) then 
						joypad.set({Up = 1})
						emu.frameadvance()
						joypad.set({A = 1})
				elseif (p == 3) then
						joypad.set({Left = 1,Up = 1})
						emu.frameadvance()
						joypad.set({A = 1})
				else 
					joypad.set({A = 1})
				end
				elseif (memory.readbyte(shirts[2]) == 0) and (memory.readbyte(tears[i]+14) == 220) and (memory.readbyte(tears[i]) == 3) then
					if (p == 0) then 
						joypad.set({Right = 1})
						emu.frameadvance()
						joypad.set({A = 1})
					elseif (p == 2) then 
						joypad.set({Right = 1,Up = 1})
						emu.frameadvance()
						joypad.set({A = 1})
					elseif (p == 3) then 
						joypad.set({Up = 1})
						emu.frameadvance()
						joypad.set({A = 1})
					else 
						joypad.set({A = 1})
					end
				elseif (memory.readbyte(shirts[2]) == 1) and (memory.readbyte(tears[i]+14) == 192) and (memory.readbyte(tears[i]) == 3) then
					if (p == 0) then 
						joypad.set({Right = 1})
						emu.frameadvance()
						joypad.set({A = 1})
					elseif (p == 2) then 
						joypad.set({Right = 1,Up = 1})
						emu.frameadvance()
						joypad.set({A = 1})
					elseif (p == 3) then 
						joypad.set({Up = 1})
						emu.frameadvance()
						joypad.set({A = 1})
					else 
						joypad.set({A = 1})
					end 
				elseif (memory.readbyte(shirts[3]) == 0) and (memory.readbyte(tears[i]+14) == 80) and (memory.readbyte(tears[i]) == 5) then
					if (p == 0) then 
						joypad.set({Down = 1})
						emu.frameadvance()
						joypad.set({A = 1})
					elseif (p == 1) then 
						joypad.set({Left = 1,Down = 1})
						emu.frameadvance()
						joypad.set({A = 1})
					elseif (p == 3) then 
						joypad.set({Left = 1})
						emu.frameadvance()
						joypad.set({A = 1})
					else 
						joypad.set({A = 1})
					end
				elseif (memory.readbyte(shirts[3]) == 1) and (memory.readbyte(tears[i]+14) == 108) and (memory.readbyte(tears[i]) == 5) then
					if (p == 0) then 
						joypad.set({Down = 1})
						emu.frameadvance()
						joypad.set({A = 1})
					elseif (p == 1) then 
						joypad.set({Left = 1,Down = 1})
						emu.frameadvance()
						joypad.set({A = 1})
					elseif (p == 3) then 
						joypad.set({Left = 1})
						emu.frameadvance()
						joypad.set({A = 1})
					else 
						joypad.set({A = 1})
					end
				elseif (memory.readbyte(shirts[4]) == 0) and (memory.readbyte(tears[i]+14) == 192 or memory.readbyte(tears[i]+14) == 248) and (memory.readbyte(tears[i]) == 5) then
					if (p == 0) then 
						joypad.set({Right = 1,Down = 1})
						emu.frameadvance()
						joypad.set({A = 1})
					elseif (p == 1) then 
						joypad.set({Down = 1})
						emu.frameadvance()
						joypad.set({A = 1})
					elseif (p == 2) then
						joypad.set({Right = 1})
						emu.frameadvance()
						joypad.set({A = 1})
					else 
						joypad.set({A = 1})
					end
				elseif (memory.readbyte(shirts[4]) == 1) and (memory.readbyte(tears[i]+14) == 164 or memory.readbyte(tears[i]+14) == 220) and (memory.readbyte(tears[i]) == 5) then
					if (p == 0) then 
						joypad.set({Right = 1,Down = 1})
						emu.frameadvance()
						joypad.set({A = 1})
					elseif (p == 1) then
						joypad.set({Down = 1})
						emu.frameadvance()
						joypad.set({A = 1})
					elseif (p == 2) then 
						joypad.set({Right = 1})
						emu.frameadvance()
						joypad.set({A = 1})
					else 
						joypad.set({A = 1})
					end 
			end
	end
end
emu.frameadvance()
end