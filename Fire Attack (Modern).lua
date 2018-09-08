memory.usememorydomain("Combined WRAM")

--[[
start = 0x03AAA4
+0x0	x
+0x2	y
+0x8	appear as fore/background
+0x10	x actual
+0x12	y actual
+0x21	sprite
+0x28	x speed
+0x2A	y speed
+0x5E	bomb timer
+0x7C	next object
0x03CF67	wario pos
]]--

--[[
Algorithm
1. Get all objects X/Y/Sprite
2. Calculate distance between said objects X/Y (based on what it is) vs. it's destination "trigger" point
2b. In the case object is past desination, base it on when it will detonate. 
3. Based on the above, rank each object on "importance"; ie. which should it focus first
4. Go and hammer/eat object
In the case a bomb/bullet is past destination and an apple/chicken is very close to it's desination, focus on apple/chicken first
]]--

local start_address = 0x03AAA4
local wario_pos = 0x03CF67
local wario_sprite_addr = 0x03D075
local sprite_count = 0x03CF66
local game_state = 0x03CF62 	--1 is when bomb explodes and everything freezes
--2 is when you get a heart
local offset = 0x7C
local color = 'white'
--Just a table to check what sprites are dangerous
local danger_sprites = {[64]=true,[65]=true,[66]=true,[67]=true}
local bomb_sprites = {[20]=true,[21]=true,[23]=true,[24]=true,[64]=true,[65]=true,[70]=true,[71]=true}
local bullet_sprites = {[26]=true,[27]=true,[29]=true,[30]=true,[66]=true,[67]=true,[72]=true,[73]=true}
local chicken_sprites = {[14]=true,[15]=true,[17]=true,[18]=true}
local heart_sprites = {[38]=true,[39]=true,[40]=true,[41]=true,[42]=true,[43]=true,[44]=true,[45]=true}
local apple_sprite = 32
local dead_sprites = {[0]=true,[16]=true,[19]=true,[22]=true,[25]=true,[28]=true,[31]=true,[33]=true,[34]=true,[35]=true,[36]=true,[37]=true,[61]=true,[63]=true,[74]=true,[75]=true,[76]=true,[77]=true,[78]=true,[79]=true,[80]=true,[81]=true,[82]=true,[83]=true,[84]=true,[85]=true,[86]=true,[87]=true}
local positions = {[0] = "Top Left", [1] = "Top Right", [2] = "Bottom Left", [3] = "Bottom Right"}
local wario_sprite = {[0]=true,[1]=true,[2]=true,[3]=true}
--[[
start = 0x03AAA4
+0x0	x
+0x2	y
+0x8	appear as fore/background
+0x10	x actual
+0x12	y actual
+0x21	sprite
+0x28	x speed
+0x2A	y speed
+0x5E	bomb timer
+0x7C	next object
0x03CF67	wario pos
]]--
local function GetStats(addr,o)
    o = o or {} --Construct a table if we didn't get one
	o.address = bizstring.hex(addr)
    o.x = memory.readbyte(addr)
    o.y = memory.readbyte(addr+0x2)
    o.foreground = memory.readbyte(addr+0x8)
    o.sprite = memory.readbyte(addr+0x21)
	o.distance = 0
	o.wario_dest = "Unknown"	--where wario should be
	if bomb_sprites[o.sprite] ~= nil then
	--bobomb seems to be triggered by y pos <= 113	
		o.obj_type = "Bomb"
		o.distance = o.y - 113
		if o.x > 127 and o.x < 247 then	--it's oddly bugged; 248+ counts as bottom left
			o.wario_dest = "Bottom Right"
		else
			o.wario_dest = "Bottom Left"
		end
	elseif bullet_sprites[o.sprite] ~= nil then
	--bullet bills seems to be triggered if x pos >= 62 from left, or x pos <= 178 from right
		o.obj_type = "Bullet"
		if o.x > 127 and o.x <= 247 then	--it's oddly bugged; 248+ counts as bottom left
			o.distance = o.x - 178 --178 is when bomb is reachable from the right
			o.wario_dest = "Top Right"
		else
			o.distance = (o.x >= 248 ) and o.x - 62 or 62 - o.x --reachable from left; the condition is due to the bug where 248+ counts as left
			o.wario_dest = "Top Left"
		end
	elseif chicken_sprites[o.sprite] ~= nil then
	--chicken lays egg if wario is present, and y <= 97. However, you won't make it if diagonally away from chicken, so check instead if y <= 100
		o.obj_type = "Chicken"
		o.distance = o.y - 100
		if o.x > 127 and o.x <= 247 then	--it's oddly bugged; 248+ counts as bottom left
			o.wario_dest = "Bottom Right"
		else
			o.wario_dest = "Bottom Left"
		end
	elseif o.sprite == apple_sprite then
	--apple is devoured if x >= 83 or x <= 157
		o.obj_type = "Apple"
		if o.x > 127 and o.x <= 247 then	--it's oddly bugged; 248+ counts as bottom left
			o.distance = o.x - 157 --178 is when bomb is reachable from the right
			o.wario_dest = "Top Right"
		else
			o.distance = (o.x >= 248) and o.x - 83 or  83 - o.x --reachable from left; the condition is due to the bug where 248+ counts as left
			o.wario_dest = "Top Left"
		end
	elseif heart_sprites[o.sprite] ~= nil then
		o.obj_type = "Heart"
	elseif dead_sprites[o.sprite] ~= nil then
		o.obj_type = "Dead"
	else
		o.obj_type = "Unknown"
	end
    o.x_speed = memory.readbyte(addr+0x28)
    o.y_speed = memory.readbyte(addr+0x2A)
    o.timer = memory.readbyte(addr+0x5E)
    --... And so on
    return o
end

function return_objects()
	local objects = {}
--load objects into tables
	for i = start_address, 0x03AE84, offset do	--enough start_address 8 npcs
	--(i-start_address)/0x07c to get in terms of 0,1,2,3,4,5,6,...
		index = (i-start_address)/offset
		--console.log(index)
		objects[index] = GetStats(i)
	end
	
	return objects
end


function display()
	local display_x = 0
	local display_y = 0
	local index
	local closest = 0
	local newLow = 100000	--threshold for comparison
	local l_sprite_count = memory.readbyte(sprite_count)
	--check conditions; making them separate for readibility
	local danger
	local apple_reachable
	local chicken
	local dead_npc
	local x,y = 0,0
	local objects = return_objects()
	--find closest object index
	for i = 0, #objects do
		if objects[i].obj_type ~= "Dead" then
			if (objects[i].distance < newLow) and objects[i].obj_type ~= "Dead" then
				newLow = objects[i].distance
				closest = i
			end
		end
	end
	--display this
	for i = 0, #objects do
		display_x = client.transformPointX(objects[i].x)
		dead_npc = objects[i].obj_type == "Dead"
		danger = false
		apple_reachable = false
		chicken = false
		if objects[i].distance <= 1 and not dead_npc then
			danger = (objects[i].obj_type == "Bomb" or objects[i].obj_type == "Bullet")
			apple_reachable = objects[i].obj_type == "Apple"
			chicken = objects[i].obj_type == "Chicken"
		end
		if dead_npc then color = 'black' 
		else 
			if danger then color = 'red'
			elseif apple_reachable then color = 'pink'
			elseif chicken then color = 'yellow'
			else color = 'white'
			end
			display_y = client.transformPointY(objects[i].y)
			gui.text(display_x,display_y,"Spr:"..objects[i].sprite,color)
		end
		display_y = i*15+15
		gui.text(0,display_y,"X:"..objects[i].x.."Y:"..objects[i].y.."Spr:"..objects[i].sprite.."D:"..objects[i].distance,color)
		gui.text(0,0,"Spr:"..l_sprite_count,'white')
		gui.text(0,200,closest.." "..objects[closest].wario_dest)
		gui.text(0,215,"X:"..objects[closest].x.."Y:"..objects[closest].y.."Spr:"..objects[closest].sprite.."D:"..objects[closest].distance)
	end
end

function move()
	local objects = {}
	local index
	local closest = 0
	local newLow = 100000	--threshold for comparison
	local l_wario = memory.readbyte(wario_pos)
	local objects = return_objects()
	local case
	--check conditions; making them separate for readibility
	local danger = false
	local apple_reachable = false
	local chicken = false
	local dead_npc
	local can_move
	local wrong_spot
	--find closest object index
	for i = 0, #objects do
		if objects[i].obj_type ~= "Dead" then
			if (objects[i].distance < newLow) and objects[i].obj_type ~= "Dead" then
				newLow = objects[i].distance
				closest = i
			end
		end
	end
	wrong_spot = positions[l_wario] ~= objects[closest].wario_dest and objects[closest].wario_dest ~= "Unknown"
	can_move = wario_sprite[memory.readbyte(wario_sprite_addr)] == true
	
	if newLow < 10 and wrong_spot and can_move  then
		if positions[l_wario] == "Top Left" then
			if objects[closest].wario_dest == "Top Right" then
				joypad.set({Right = 1})
				case = 0
			elseif objects[closest].wario_dest == "Bottom Left" then
				joypad.set({Down = 1})
				case = 1
			elseif objects[closest].wario_dest == "Bottom Right" then
				joypad.set({Right = 1,Down = 1})
				case = 2
			end
		elseif positions[l_wario] == "Top Right" then
			if objects[closest].wario_dest == "Top Left" then
				joypad.set({Left = 1})
				case = 3	
			elseif objects[closest].wario_dest == "Bottom Left" then
				joypad.set({Left = 1, Down = 1})
				case = 4
			elseif objects[closest].wario_dest == "Bottom Right" then
				joypad.set({Down = 1})
				case = 5
			end
		elseif positions[l_wario] == "Bottom Left" then
			if objects[closest].wario_dest == "Top Left" then
				joypad.set({Up = 1})
				case = 6	
			elseif objects[closest].wario_dest == "Top Right" then
				joypad.set({Right = 1, Up = 1})
				case = 7
			elseif objects[closest].wario_dest == "Bottom Right" then
				joypad.set({Right = 1})
				case = 8
			end
		elseif positions[l_wario] == "Bottom Right" then
			if objects[closest].wario_dest == "Top Left" then
				joypad.set({Left = 1, Up = 1})
				case = 9	
			elseif objects[closest].wario_dest == "Top Right" then
				joypad.set({Up = 1})
				case = 10
			elseif objects[closest].wario_dest == "Bottom Left" then
				joypad.set({Left = 1})
				case = 11
			end
		end
	end
	
	--a different loop, since we need to use closest from before
	for i = 0, #objects do
		danger = false
		apple_reachable = false
		chicken = false
		dead_npc = objects[i].obj_type == "Dead"
		if objects[i].distance <= 1 and not dead_npc then
			danger = (objects[i].obj_type == "Bomb" or objects[i].obj_type == "Bullet")
			apple_reachable = objects[i].obj_type == "Apple"
			chicken = objects[i].obj_type == "Chicken"
		end
		--checking if wrong spot, to prevent smashing apples/chickens
		if danger and not wrong_spot then 
			joypad.set({A = 1})
			emu.frameadvance()
		end
	end
end
	
while true do
move()
-- display()
emu.frameadvance()
end
