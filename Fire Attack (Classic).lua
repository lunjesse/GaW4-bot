memory.usememorydomain("Combined WRAM")

function move_fire(dest)
local player = memory.readbyte(0x03C130)
local hit = memory.readbyte(0x03C132)
--	console.log(dest)
	if (player == dest) then
		if (hit == 0) then joypad.set({A = true}) return end
	else
		if (player == 0 and dest == 1) then joypad.set({Right = true}) 
		elseif (player == 0 and dest == 2) then joypad.set({Down = true}) 
		elseif (player == 0 and dest == 3) then joypad.set({Down = true, Right = true}) 
		elseif (player == 1 and dest == 0) then joypad.set({Left = true}) 
		elseif (player == 1 and dest == 2) then joypad.set({Down = true, Left = true}) 
		elseif (player == 1 and dest == 3) then joypad.set({Down = true})
		elseif (player == 2 and dest == 0) then joypad.set({Up = true})
		elseif (player == 2 and dest == 1) then joypad.set({Up = true, Right = true})
		elseif (player == 2 and dest == 3) then joypad.set({Right = true})
		elseif (player == 3 and dest == 0) then joypad.set({Up = true, Left = true})
		elseif (player == 3 and dest == 1) then joypad.set({Up = true})
		elseif (player == 3 and dest == 2) then joypad.set({Left = true})
		end
	end
end

while true do
local fire_address = 0x03AB18
local fire
local pos = {[4] = 0, [10] = 1, [16] = 2, [23] = 3}	--positions of fire, and where the player should be at
for i = 0, 7 do
	fire = memory.readbyte(fire_address+(0x7C*i))
	--4 cases: top left, top right, bottom left, bottom right
	gui.text(0,60+15*i,i.." f "..fire) 
	if (pos[fire] ~= nil) then	--this means the positions exists
		move_fire(pos[fire])
	end
end
emu.frameadvance()
console.clear()
end
