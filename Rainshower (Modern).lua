memory.usememorydomain("Combined WRAM")
--For the positions to check at the first pair of ropes based on current balloon speed. Speeds 0-5 is technically never reached, but placeholder

local balloon_sprites = {[0x3B]="Green",[0x3C]="Green",[0x2B]="Red",[0x2C]="Red",[0x33]="Black",[0x34]="Black",[0x1E]="Blue",[0x1F]="Blue",[0x19]="Moon"}
--adresses
local mario_action = 0x03DDF4	--whats mario doing now
local mario_pos = 0x03DDEC
local balloon_speed = 0x03E456
local ropes = {["top left"]=0x03DDF8,["top right"]=0x03DDF9,["bottom left"]=0x03DDFA,["bottom right"]=0x03DDFB}	--Ropes pulled boolean from Top Left, Top Right, Bottom Left, Bottom Right

function move(spot) --move to this spot and press A
	while memory.readbyte(mario_action) ~= 8 do	--Mario can't move if not this value
		emu.frameadvance()
	end
	if memory.readbyte(mario_pos) == spot then	--Mario's at the spot
		joypad.set({A = 1})
		emu.frameadvance()
		return
	else	--pressing multiple directions at once will make the game use only the valid one and ignore the other
		if spot == 0 then
			joypad.set({Left = 1,Up = 1})
			emu.frameadvance()
			return move(spot)
		elseif spot == 1 then
			joypad.set({Right = 1,Up = 1})
			emu.frameadvance()
			return move(spot)
		elseif spot == 2 then
			joypad.set({Left = 1,Down = 1})
			emu.frameadvance()
			return move(spot)
		elseif spot == 3 then
			joypad.set({Right = 1,Down = 1})
			emu.frameadvance()
			return move(spot)
		end
	end
end

while true do
	--For top rope
	local speed1 = {
	[0]=50,[1]=50,[2]=50,[3]=50,[4]=50,
	[5]=50,[6]=47,[7]=45,[8]=45,[9]=45,
	[10]=43,[11]=43,[12]=40,[13]=40,[14]=38,
	[15]=35,[16]=35,[17]=35,[18]=33,[19]=33,[20]=30}
	--For bottom rope
	local speed2 = {[0]=103,[1]=103,[2]=103,[3]=103,[4]=103,
	[5]=103,[6]=100,[7]=98,[8]=98,[9]=98,
	[10]=96,[11]=96,[12]=93,[13]=93,[14]=91,
	[15]=88,[16]=88,[17]=88,[18]=86,[19]=86,[20]=83}
	local l_balloon_speed = memory.readbyte(balloon_speed)	--global speed for all objects (difficulty I guess)
	local balloon_alive, passed_top_rope, passed_bottom_rope
	local balloon_x,balloon_y, l_balloon_sprite
	local case = 0	--debug
	for i = 0x03C7E4, 0x03CE30, 0x7c do	--First Balloon's X pos; offset of others is 7C. Enough for 15 balloons.
	--[[Glossary:
	memory.read_u16_le(i+0x1A) is balloon speed. It ranges from 80 -> 320, with an increase of 16 every 20 points. It can never be outside this range for a balloon or moon, so use this to check if balloon is dead
	memory.readbyte(0x03E456) is balloon speed multiplier. It's multiplied by 16 to give the above; useful for making a check for when to detect balloon. Starts at 5 for easy, 7 for hard and 20 for very hard.
	speed1[memory.readbyte(0x03E456)] is used to determine when to detect a balloon to prevent the occurance of 2 balloons from both left and right falling around the same time. Varies based on speed of the balloon
	memory.readbyte(i+0x11) is sprite. I can't find the IDs for the objects, so this is the best approach for now
		Green - 0x3B,0x3C 
		Red - 0x2B,0x2C 
		Black - 0x33,0x34 
		Blue - 0x1E, 0x1F 
		Moon - 0x19 

	bit.check(memory.readbyte(i+0x54),2) is a flag for passing the first rope
	bit.check(memory.readbyte(i+0x54),3) is a flag for passing the second rope
	memory.readbyte(i) is the "X" position of the balloon/moon. When falling it can only be at these locations:
		green balloon - 87, 155
		red balloon - 71, 176
		black balloon - 50, 202
		blue balloon - 29, 220
local balloon_x_dest = {[87]="Green",[155]="Green",[71]="Red",[176
	memory.readbyte(i+2) is the "Y" position of the balloon/moon.
	move(spot) is a function for moving to said spot and pressing A. Made to reduce copy-pasting of code.
	]]--
		passed_top_rope = bit.check(memory.readbyte(i+0x54),2)
		passed_bottom_rope = bit.check(memory.readbyte(i+0x54),3)
		balloon_y = memory.readbyte(i+2)
		balloon_x = memory.readbyte(i)
		l_balloon_sprite = memory.readbyte(i+0x11)
		balloon_alive = (memory.read_u16_le(i+0x1A) > 70 and memory.read_u16_le(i+0x1A) < 330)
		if balloon_alive then	--speed must be between 70 and 330; probably better check be nice
			if passed_top_rope == false then	--Has not passed the first rope
				if balloon_x < 120 and balloon_y >= speed1[l_balloon_speed]  then	--Check if heading left and almost near first rope
					if (balloon_sprites[l_balloon_sprite] == "Green" or balloon_sprites[l_balloon_sprite] == "Black") and memory.readbyte(ropes["top left"]) == 1 then	--Green balloon and black balloon share same vicims
						move(0)
						case = 0
					elseif (balloon_sprites[l_balloon_sprite] == "Red" or balloon_sprites[l_balloon_sprite] == "Blue") and memory.readbyte(ropes["top left"]) == 0 then	--Red balloon and blue balloon
						move(0)
						case = 1
					elseif balloon_sprites[l_balloon_sprite] == "Moon" and ((memory.readbyte(ropes["top left"]) == 0 and (balloon_x ~= 29 or balloon_x ~= 71)) or (memory.readbyte(ropes["top left"]) == 1 and (balloon_x ~= 87 or balloon_x ~= 50))) then --The moon in these 2 spots and you're not underneath either
						move(0)
						case = 2
					end
				elseif balloon_x > 120 and balloon_y >= speed1[l_balloon_speed]  then	--Check if heading right and almost near the first rope
					if balloon_sprites[l_balloon_sprite] == "Red" and memory.readbyte(ropes["top right"]) == 1 then	--Red balloon
						move(1)
						case = 3
					elseif balloon_sprites[l_balloon_sprite] == "Black" and memory.readbyte(ropes["top right"]) == 0 then --Black balloon
						move(1)
						case = 4
					elseif balloon_sprites[l_balloon_sprite] == "Moon" and ((memory.readbyte(ropes["top right"]) == 0 and balloon_x == 176) or (memory.readbyte(ropes["top right"]) == 1 and balloon_x == 202)) then
						move(1)
						case = 5
					end
				end
			elseif  passed_top_rope == true and passed_bottom_rope == false then
				if balloon_x < 120 and balloon_y >= speed2[l_balloon_speed] then	--Check if heading left and almost near second rope
					if balloon_sprites[l_balloon_sprite] == "Red" and memory.readbyte(ropes["bottom left"]) == 1 then	--Red balloon
						move(2)
						case = 6
					elseif balloon_sprites[l_balloon_sprite] == "Black" and memory.readbyte(ropes["bottom left"]) == 0 then --Black balloon
						move(2)
						case = 7
					elseif balloon_sprites[l_balloon_sprite] == "Moon" and ((memory.readbyte(ropes["bottom left"]) == 1 and balloon_x == 50) or (memory.readbyte(ropes["bottom left"]) == 0 and balloon_x == 71)) then	--Moon
						move(2)
						case = 8
					end
				elseif balloon_x > 120 and balloon_y >= speed2[l_balloon_speed]  then	--Check if heading right and almost near the first rope
					if (balloon_sprites[l_balloon_sprite] == "Red" or balloon_sprites[l_balloon_sprite] == "Blue") and memory.readbyte(ropes["bottom right"]) == 0 then	--Red balloon and blue balloon
						move(3)
						case = 9
					elseif (balloon_sprites[l_balloon_sprite] == "Green" or balloon_sprites[l_balloon_sprite] == "Black") and memory.readbyte(ropes["bottom right"]) == 1 then	--Green and black balloon
						move(3)
						case = 10
					elseif balloon_sprites[l_balloon_sprite] == "Moon" and ((memory.readbyte(ropes["bottom right"]) == 0 and (balloon_x ~= 176 or balloon_x ~= 220)) or (memory.readbyte(ropes["bottom right"]) == 1 and (balloon_x ~= 155 or balloon_x ~= 202))) then --The moon in these 2 spots and you're not underneath either
						move(3)
						case = 11
					end
				end
			end --end top rope/bottom rope check
		end	--end balloon_alive check
		gui.text(0,100,case)
	end
	emu.frameadvance()
end
