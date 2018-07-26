memory.usememorydomain("Combined WRAM")
local food_address = {[1] = 0x03C748, [2] = 0x03C75C, [3] = 0x03C770, [4] = 0x03C784}
local food_state = {["Raw"]=0,["Cooked"]=1,["Burnt"]=2}
--addresses
local yoshi_x = 0x03C358
local peach_x = 0x03C351	--where peach is
local peach_dir = 0x03C352	--where is peach facing
local yoshi_time_adr = 0x03C634
local yoshi_food_count = 0x03C35B	--how much yoshi has ate in this form
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

--advance frame by "frames" amount.
local function frame_advance(frames)
	if frames ~= nil then 
		repeat
			emu.frameadvance()
			frames = frames - 1
		until frames == 0
	else
		emu.frameadvance()
	end
end


local function move(direction)
	if direction == "right" then
		joypad.set({Right = true}) 
		frame_advance(3)
	elseif direction == "left" then
		joypad.set({Left = true}) 
		frame_advance(3)
	end
end

function feed_yoshi(destination,action)
--action is feed or cook
	--Yoshi is always behind peach, so ignore him
	local peach = memory.readbyte(peach_x)
	local direction = memory.readbyte(peach_dir)
	local left = {[0]=true,[2]=true,[8]=true,[12]=true}
	local right = {[1]=true,[3]=true,[9]=true,[13]=true}
	local turned_correctly
	--array for readibility purposes
	local dest_array = {["far left"]=0,["left"]=1,["middle"]=2,["right"]=3,["far right"]=4}
	local peach_array = {["far left"]=0,["left"]=1,["right"]=2,["far right"]=3}
	
	if destination == dest_array["far left"] then	--food is far left side
		if peach > peach_array["far left"] then
			repeat
				move("left")
				peach = memory.readbyte(peach_x)	--updates peach address; otherwise never does
			until peach == peach_array["far left"]
		elseif peach == peach_array["far left"] then	--peach is at the right spot
		--feed food, or cook it. [direction]== nil means Peach isn't turned correctly
			turned_correctly = (action == "feed" and right[direction] == nil) or (action == "cook" and left[direction] == nil)
			if turned_correctly then
				joypad.set({A = true}) 
				emu.frameadvance()
			end
		end
	
	elseif destination == dest_array["far right"] then	--food is far right side
		if peach < peach_array["far right"] then
			repeat
				move("right")
				peach = memory.readbyte(peach_x)	--updates peach address; otherwise never does
			until peach == peach_array["far right"]	--otherwise "peach" never updates
		elseif peach == peach_array["far right"] then
			turned_correctly = (action == "feed" and left[direction] == nil) or (action == "cook" and right[direction] == nil)
			if turned_correctly then
				joypad.set({A = true}) 
				emu.frameadvance()
			end
		end
		
	elseif destination == dest_array["left"] then	--food is 1 step to the right
		if peach == peach_array["far left"] then
			turned_correctly = (action == "feed" and left[direction] == nil) or (action == "cook" and right[direction] == nil)
			if turned_correctly then
				joypad.set({A = true}) 
				emu.frameadvance()
			end
		end
		if peach == peach_array["left"] then
			turned_correctly = (action == "feed" and right[direction] == nil) or (action == "cook" and left[direction] == nil)
			if turned_correctly then
				joypad.set({A = true}) 
				emu.frameadvance()
			end
		end
		if peach > peach_array["left"] then
			repeat
				move("left")
				peach = memory.readbyte(peach_x)	--updates peach address; otherwise never does
			until peach == peach_array["left"]
		end
		
	elseif destination == dest_array["middle"] then	--food is 2 steps to the right
		if peach > peach_array["right"] then
			repeat
				move("left")
				peach = memory.readbyte(peach_x)	--updates peach address; otherwise never does
			until peach == peach_array["right"]
		end
		if peach < peach_array["left"] then
			repeat
				move("right")
				peach = memory.readbyte(peach_x)	--updates peach address; otherwise never does
			until peach == peach_array["left"]
		end
		
		if peach == peach_array["left"] then
			turned_correctly = (action == "feed" and left[direction] == nil) or (action == "cook" and right[direction] == nil)
			if turned_correctly then
				joypad.set({A = true}) 
				emu.frameadvance()
			end
		end
		if peach == peach_array["right"] then
			turned_correctly = (action == "feed" and right[direction] == nil) or (action == "cook" and left[direction] == nil)
			if turned_correctly then
				joypad.set({A = true}) 
				emu.frameadvance()
			end
		end
	
	elseif destination == dest_array["right"] then	--food is 3 steps to the right
		if peach < peach_array["right"] then
			repeat
				move("right")
				peach = memory.readbyte(peach_x)	--updates peach address; otherwise never does
			until peach == peach_array["right"]
		end
		if peach == peach_array["right"] then
			turned_correctly = (action == "feed" and left[direction] == nil) or (action == "cook" and right[direction] == nil)
			if turned_correctly then
				joypad.set({A = true}) 
				emu.frameadvance()
			end
		end
		if peach == peach_array["far right"] then
			turned_correctly = (action == "feed" and right[direction] == nil) or (action == "cook" and left[direction] == nil)
			if turned_correctly then
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
	local direction = memory.readbyte(peach_dir)
	local nearest_y = 0
	local nearest_i = 0
	local nearest_x = 0
	local yoshi_time = memory.readbyte(yoshi_time_adr)
	local action = "Nothing"
	for i = 1, 4 do
		food[i] = GetStats(food_address[i])
		if food[i].exists > 0 then
			gui.drawText(3,i*15,i..": "..food[i].y_timer.."/"..food[i].y_min_timer.."x "..food[i].x.."("..food[i].state..")")
			--Find the nearest food in terms of the y_min value
			if (nearest_y == 0 or nearest_y >= food[i].y_min_timer - food[i].y_timer) then
				nearest_y = (food[i].y_min_timer+9) - food[i].y_timer	--The 9 is for the frames needed for Yoshi to eat the food
				nearest_x = food[i].x
				nearest_i = i	--debug
			end
		end
	end
	if nearest_y > 0 and food[nearest_i].state ~= food_state["Cooked"] then	--it's not raw nor burnt
		action = "cook"
		feed_yoshi(nearest_x,action)
	elseif nearest_y > 0 and food[nearest_i].state == food_state["Cooked"] then
		if (yoshi_time == 0 or yoshi_time == 24) then
			--yoshi is available to be fed; need to find a better way to determine this
			action = "feed"
			feed_yoshi(nearest_x,action)
		else
			--food is cooked, but yoshi is "busy", so don't atempt to feed
			action = "cook"
			feed_yoshi(nearest_x,action)
		end
	end
	gui.drawText(0,85,nearest_i..": Time:"..nearest_y.." X:"..nearest_x)
	gui.drawText(0,100,"Yoshi:"..memory.readbyte(yoshi_x).."Food:"..memory.readbyte(yoshi_food_count))
	gui.drawText(0,145,"Peach:"..memory.readbyte(peach_x).."("..direction..")")
	gui.drawText(0,130,action)
	emu.frameadvance()
end
