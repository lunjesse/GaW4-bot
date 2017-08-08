memory.usememorydomain("Combined WRAM")
local t1 = {[1]=0x03A5B6,[2]=0x03A61E,[3]=0x03A686,[4]=0x03A6EE,[5]=0x03A756,[6]=0x03A7BE,[7]=0x03A826} --stick positions

function move(d,a)
if (d == true) then
local p = memory.readbyte(0x03A54E) -- your position
gui.drawText(3,3,"a: "..a.."p:"..p,'RED')
	if (a == 4) and (p == 1) then
		joypad.set({Left = 1}) 
	elseif (a == 4) and (p == 2) then
		joypad.set({B = 1}) 
	elseif (a == 12) and (p == 0) then
		joypad.set({Right = true}) 
	elseif (a == 12) and (p == 2) then
		joypad.set({B = 1}) 
	elseif (a == 18) and (p == 1) then
		joypad.set({Right = 1}) 
	elseif (a == 18) and (p == 0) then
		joypad.set({A = true}) 
	end
end
end
while true do
	for i = 1, 7 do 
		if (memory.readbyte(t1[i]+2)<=0x10) then
			if (memory.readbyte(t1[i]) == 4) or (memory.readbyte(t1[i]) == 12) or (memory.readbyte(t1[i]) == 18) then
				move(true,memory.readbyte(t1[i])) end
		end
	end
	emu.frameadvance()
end
--(memory.readbyte(t1[i]+2)<=0x10)
-- minus 8 is sprite. minus 4 is timer plus 2 is land on trampoline state.