memory.usememorydomain("Combined WRAM")
local t = {[0]=0x03BFE0,[1]=0x03C05C,[2]=0x03C0D8,[3]=0x03C154,[4]=0x03C1D0,[5]=0x03C24C,[6]=0x03C2C8}	--X positions
function move(j)
local p = memory.readbyte(0x03C412) -- your position
gui.drawText(3,3,"a: "..j.."p:"..p,'RED')
	if (j == 0) and (p == 1) then
		joypad.set({Left = 1}) 
	elseif (j == 0) and (p == 2) then
		joypad.set({B = 1})
		emu.frameadvance()
		joypad.set({Left = 1}) 
	elseif (j == 1) and (p == 0) then
		joypad.set({Right = true}) 
	elseif (j == 1) and (p == 2) then
		joypad.set({B = 1}) 
	elseif (j == 2) and (p == 1) then
		joypad.set({Right = 1}) 
	elseif (j == 2) and (p == 0) then
		joypad.set({A = true}) 
		emu.frameadvance()
		joypad.set({Right = 1}) 
	end
end

while true do
	for i = 0, 6 do 
		if (memory.readbyte(t[i]+72) ~= 5) and (memory.readbyte(t[i]+84) ~= 0) then --compares id
			if (memory.readbyte(t[i]+82) == 0) and (memory.readbyte(t[i]+2) >= 109) and (memory.read_s16_le(t[i]+26) >= 700) then 	--compares it's vertical position 
				move(memory.readbyte(t[i]+82))	--The number of jumps it did
			elseif (memory.readbyte(t[i]+82) == 1) and (memory.readbyte(t[i]+2) >= 107) and (memory.read_s16_le(t[i]+26) >= 590) then	
				move(memory.readbyte(t[i]+82))
			elseif (memory.readbyte(t[i]+82) == 2) and (memory.readbyte(t[i]+2) >= 105) and (memory.read_s16_le(t[i]+26) >= 550) then
				move(memory.readbyte(t[i]+82))
			end
		end
	emu.frameadvance()
	end
end