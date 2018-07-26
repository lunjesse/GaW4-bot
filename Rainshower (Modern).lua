memory.usememorydomain("Combined WRAM")
--For the positions to check at the first pair of ropes based on current balloon speed. Speeds 0-5 is technically never reached, but placeholder

function move(spot) --move to this spot and press A
	while memory.readbyte(0x03DDF4) ~= 8 do	--Mario can't move if not this value
		emu.frameadvance()
	end
	if memory.readbyte(0x03DDEC) == spot then	--Mario's at the spot
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
	local speed1 = {
	[0]=50,[1]=50,[2]=50,[3]=50,[4]=50,
	[5]=50,[6]=47,[7]=45,[8]=45,[9]=45,
	[10]=43,[11]=43,[12]=40,[13]=40,[14]=38,
	[15]=35,[16]=35,[17]=35,[18]=33,[19]=33,[20]=30}
	local speed2 = {[0]=103,[1]=103,[2]=103,[3]=103,[4]=103,
	[5]=103,[6]=100,[7]=98,[8]=98,[9]=98,
	[10]=96,[11]=96,[12]=93,[13]=93,[14]=91,
	[15]=88,[16]=88,[17]=88,[18]=86,[19]=86,[20]=83}
	local ropes = {[0]=0x03DDF8,[1]=0x03DDF9,[2]=0x03DDFA,[3]=0x03DDFB}	--Ropes pulled boolean from Top Left, Top Right, Bottom Left, Bottom Right
	for i = 0x03C7E4, 0x03CE30, 0x7c do	--First Balloon's X pos; offset of others is 7C. Enough for 15 balloons.
	--[[Glossary:
	memory.read_u16_le(i+0x1A) is balloon speed. It ranges from 80 -> 320, with an increase of 16 every 20 points. It can never be outside this range for a balloon or moon, so use this to check if balloon is dead
	memory.readbyte(0x03E456) is balloon speed multiplier. It's multiplied by 16 to give the above; useful for making a check for when to detect balloon. Starts at 5 for easy, 7 for hard and 20 for very hard.
	speed1[memory.readbyte(0x03E456)] is used to determine when to detect a balloon to prevent the occurance of 2 balloons from both left and right falling around the same time. Varies based on speed of the balloon
	memory.readbyte(i+0x11) is sprite color. I can't find the IDs for the objects, so this is the best approach for now
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
	memory.readbyte(i+2) is the "Y" position of the balloon/moon.
	move(spot) is a function for moving to said spot and pressing A. Made to reduce copy-pasting of code.
	]]--
		if (memory.read_u16_le(i+0x1A) > 70 and memory.read_u16_le(i+0x1A) < 330) and  bit.check(memory.readbyte(i+0x54),2) == false then	--Has not passed the first rope; speed must be between 70 and 330
			if memory.readbyte(i) < 120 and memory.readbyte(i+2) >= speed1[memory.readbyte(0x03E456)]  then	--Check if heading left and almost near first rope
				if (memory.readbyte(i+0x11) == 0x3B or memory.readbyte(i+0x11) == 0x3C or memory.readbyte(i+0x11) == 0x33 or memory.readbyte(i+0x11) == 0x34) and memory.readbyte(ropes[0]) == 1 then	--Green balloon and black balloon share same vicims
					move(0)
				elseif (memory.readbyte(i+0x11) == 0x2B or memory.readbyte(i+0x11) == 0x2C or memory.readbyte(i+0x11) == 0x1E or memory.readbyte(i+0x11) == 0x1F) and memory.readbyte(ropes[0]) == 0 then	--Red balloon and blue balloon
					move(0)
				elseif memory.readbyte(i+0x11) == 0x19 and ((memory.readbyte(ropes[0]) == 0 and (memory.readbyte(i) ~= 29 or memory.readbyte(i) ~= 71)) or (memory.readbyte(ropes[0]) == 1 and (memory.readbyte(i) ~= 87 or memory.readbyte(i) ~= 50))) then --The moon in these 2 spots and you're not underneath either
						move(0)
				end
			elseif memory.readbyte(i) > 120 and memory.readbyte(i+2) >= speed1[memory.readbyte(0x03E456)]  then	--Check if heading right and almost near the first rope
				if (memory.readbyte(i+0x11) == 0x2B or memory.readbyte(i+0x11) == 0x2C) and memory.readbyte(ropes[1]) == 1 then	--Red balloon
					move(1)
				elseif (memory.readbyte(i+0x11) == 0x33 or memory.readbyte(i+0x11) == 0x34) and memory.readbyte(ropes[1]) == 0 then --Black balloon
					move(1)
				elseif memory.readbyte(i+0x11) == 0x19 and (memory.readbyte(ropes[1]) == 0 and memory.readbyte(i) == 176) or (memory.readbyte(ropes[1]) == 1 and memory.readbyte(i) == 202) then
					move(1)
				end
			end
		elseif (memory.read_u16_le(i+0x1A) > 70 and memory.read_u16_le(i+0x1A) < 330) and  memory.readbyte(i+2) > 76 then	--Still need to check speed in case balloon dies
			if memory.readbyte(i) < 120 and memory.readbyte(i+2) >= speed2[memory.readbyte(0x03E456)] then	--Check if heading left and almost near second rope
				if (memory.readbyte(i+0x11) == 0x2B or memory.readbyte(i+0x11) == 0x2C) and memory.readbyte(ropes[2]) == 1 then	--Red balloon
					move(2)
				elseif (memory.readbyte(i+0x11) == 0x33 or memory.readbyte(i+0x11) == 0x34) and memory.readbyte(ropes[2]) == 0 then --Black balloon
					move(2)
				elseif memory.readbyte(i+0x11) == 0x19 and (memory.readbyte(ropes[2]) == 1 and memory.readbyte(i) == 50) or (memory.readbyte(ropes[2]) == 0 and memory.readbyte(i) == 71) then	--Moon
					move(2)
				end
			elseif memory.readbyte(i) > 120 and memory.readbyte(i+2) >= speed2[memory.readbyte(0x03E456)]  then	--Check if heading right and almost near the first rope
				if (memory.readbyte(i+0x11) == 0x2B or memory.readbyte(i+0x11) == 0x2C or memory.readbyte(i+0x11) == 0x1E or memory.readbyte(i+0x11) == 0x1F) and memory.readbyte(ropes[3]) == 0 then	--Red balloon and blue balloon
					move(3)
				elseif (memory.readbyte(i+0x11) == 0x3B or memory.readbyte(i+0x11) == 0x3C or memory.readbyte(i+0x11) == 0x33 or memory.readbyte(i+0x11) == 0x34) and memory.readbyte(ropes[3]) == 1 then	--Green and black balloon
					move(3)
				elseif memory.readbyte(i+0x11) == 0x19 and ((memory.readbyte(ropes[3]) == 0 and (memory.readbyte(i) ~= 176 or memory.readbyte(i) ~= 220)) or (memory.readbyte(ropes[3]) == 1 and (memory.readbyte(i) ~= 155 or memory.readbyte(i) ~= 202))) then --The moon in these 2 spots and you're not underneath either
					move(3)
				end
			end
		end
	end
	emu.frameadvance()
end