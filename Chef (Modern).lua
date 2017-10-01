memory.usememorydomain("Combined WRAM")
food_address = {[1] = 0x03C748, [2] = 0x03C75C, [3] = 0x03C770, [4] = 0x03C784}
x_yoshi = 0x03C358
--[[
Peach 03C351
Peach direction 03C352
0 is left, 1 is right
If food is at col 0, peach should be at col 0 and 0 direction

If food is at col 1, peach should be at col 0 and 1 direction
If food is at col 1, peach should be at col 1 and 0 direction

If food is at col 2, peach should be at col 1 and 1 direction
If food is at col 2, peach should be at col 2 and 0 direction

If food is at col 3, peach should be at col 2 and 1 direction
If food is at col 3, peach should be at col 3 and 0 direction

If food is at col 4, peach should be at col 3 and 1 direction
Yoshi should be at whatever col food is if its the target
]]--



local function move(direction)
	if direction == "right" then
		joypad.set({Right = true}) 
		emu.frameadvance()
		emu.frameadvance()
		emu.frameadvance()
	elseif direction == "left" then
		joypad.set({Left = true}) 
		emu.frameadvance()
		emu.frameadvance()
		emu.frameadvance()
	end
end
local function travel(destination)
	local peach = memory.readbyte(0x03C351)
	local direction = memory.readbyte(0x03C352)
	local left = {[0]=true,[2]=true,[8]=true,[12]=true}
	local right = {[1]=true,[3]=true,[9]=true,[13]=true}
	
	if destination == 0 then	--food is far left side
		if peach > 0 then
			repeat
				move("left")
			until memory.readbyte(0x03C351) == 0	--otherwise "peach" never updates
		elseif peach == 0 then
			if left[direction] == nil then
				joypad.set({A = true}) 
				emu.frameadvance()
			end
		end
	
	elseif destination == 4 then	--food is far right side
		if peach < 3 then
			repeat
				move("right")
			until memory.readbyte(0x03C351) == 3	--otherwise "peach" never updates
		elseif peach == 3 then
			if right[direction] == nil then
				joypad.set({A = true}) 
				emu.frameadvance()
			end
		end
		
	elseif destination == 1 then	--food is 1 step to the right
		if peach == 0 then
			if right[direction] == nil then
				joypad.set({A = true}) 
				emu.frameadvance()
			end
		end
		if peach == 1 then
			if left[direction] == nil then
				joypad.set({A = true}) 
				emu.frameadvance()
			end
		end
		if peach > 1 then
			repeat
				move("left")
			until memory.readbyte(0x03C351) == 1	--otherwise "peach" never updates
		end
	
	elseif destination == 2 then	--food is 2 steps to the right
		if peach > 2 then
			repeat
				move("left")
			until memory.readbyte(0x03C351) == 2	--otherwise "peach" never updates
		end
		if peach < 1 then
			repeat
				move("right")
			until memory.readbyte(0x03C351) == 1	--otherwise "peach" never updates
		end
		
		if peach == 1 then
			if right[direction] == nil then
				joypad.set({A = true}) 
				emu.frameadvance()
			end
		end
		if peach == 2 then
			if left[direction] == nil then
				joypad.set({A = true}) 
				emu.frameadvance()
			end
		end
		
	elseif destination == 3 then	--food is 3 steps to the right
		if peach < 2 then
			repeat
				move("right")
			until memory.readbyte(0x03C351) == 2	--otherwise "peach" never updates
		end
		if peach == 2 then
			if right[direction] == nil then
				joypad.set({A = true}) 
				emu.frameadvance()
			end
		end
		if peach == 3 then
			if left[direction] == nil then
				joypad.set({A = true}) 
				emu.frameadvance()
			end
		end	
	end		--this ends destination if
end

function travel2(destination)
	--Yoshi is always behind peach, so ignore him
	local peach = memory.readbyte(0x03C351)
	local direction = memory.readbyte(0x03C352)
	local left = {[0]=true,[2]=true,[8]=true,[12]=true}
	local right = {[1]=true,[3]=true,[9]=true,[13]=true}
	
	if destination == 0 then	--food is far left side
		if peach > 0 then
			repeat
				move("left")
			until memory.readbyte(0x03C351) == 0	--otherwise "peach" never updates
		elseif peach == 0 then
			if right[direction] == nil then
				joypad.set({A = true}) 
				emu.frameadvance()
			end
		end
	
	elseif destination == 4 then	--food is far right side
		if peach < 3 then
			repeat
				move("right")
			until memory.readbyte(0x03C351) == 3	--otherwise "peach" never updates
		elseif peach == 3 then
			if left[direction] == nil then
				joypad.set({A = true}) 
				emu.frameadvance()
			end
		end
		
	elseif destination == 1 then	--food is 1 step to the right
		if peach == 0 then
			if left[direction] == nil then
				joypad.set({A = true}) 
				emu.frameadvance()
			end
		end
		if peach == 1 then
			if right[direction] == nil then
				joypad.set({A = true}) 
				emu.frameadvance()
			end
		end
		if peach > 1 then
			repeat
				move("left")
			until memory.readbyte(0x03C351) == 1	--otherwise "peach" never updates
		end
		
	elseif destination == 2 then	--food is 2 steps to the right
		if peach > 2 then
			repeat
				move("left")
			until memory.readbyte(0x03C351) == 2	--otherwise "peach" never updates
		end
		if peach < 1 then
			repeat
				move("right")
			until memory.readbyte(0x03C351) == 1	--otherwise "peach" never updates
		end
		
		if peach == 1 then
			if left[direction] == nil then
				joypad.set({A = true}) 
				emu.frameadvance()
			end
		end
		if peach == 2 then
			if right[direction] == nil then
				joypad.set({A = true}) 
				emu.frameadvance()
			end
		end
	
	elseif destination == 3 then	--food is 3 steps to the right
		if peach < 2 then
			repeat
				move("right")
			until memory.readbyte(0x03C351) == 2	--otherwise "peach" never updates
		end
		if peach == 2 then
			if left[direction] == nil then
				joypad.set({A = true}) 
				emu.frameadvance()
			end
		end
		if peach == 3 then
			if right[direction] == nil then
				joypad.set({A = true}) 
				emu.frameadvance()
			end
		end	
	end		--this ends destination if
end
local function GetStats(addr,o)
    o= o or {} --Construct a table if we didn't get one
	o.address = bizstring.hex(addr)
    o.exists = memory.readbyte(addr)
    o.x = memory.readbyte(addr+0x2)
    o.y_timer = memory.readbyte(addr+0x5)
    o.y_min_timer = memory.readbyte(addr+0x6)
    o.x_sprite = memory.readbyte(addr+0x7)
    o.bounce = memory.readbyte(addr+0x9)
    o.state = memory.readbyte(addr+0xA)
    --... And so on
    return o
end
while true do
	local food = {}
	local nearest_y = 0
	local nearest_i = 0
	local nearest_x = 0
	for i = 1, 4 do
		food[i] = GetStats(food_address[i])
		if food[i].exists > 0 then
			gui.drawText(3,i*15,i..": "..food[i].y_timer.."/"..food[i].y_min_timer.."x "..food[i].x)
			--Find the nearest food in terms of the y_min value
			if (nearest_y == 0 or nearest_y >= food[i].y_min_timer - food[i].y_timer) then
				nearest_y = (food[i].y_min_timer+9) - food[i].y_timer	--The 9 is for the frames needed for Yoshi to eat the food
				nearest_x = food[i].x
				nearest_i = i	--debug
			end
		end
	end
	if nearest_y > 0 and food[nearest_i].state ~= 1 then	--it's not raw nor burnt
		travel(nearest_x)
	elseif nearest_y > 0 and food[nearest_i].state == 1 then
		travel2(nearest_x)
	end
	gui.drawText(0,85,nearest_i..": Time:"..nearest_y.." X:"..nearest_x)
	gui.drawText(0,100,"Yoshi:"..memory.readbyte(x_yoshi).."Food:"..memory.readbyte(0x03C35B))
	gui.drawText(0,115,"Peach:"..memory.readbyte(0x03C351))
	emu.frameadvance()
end
