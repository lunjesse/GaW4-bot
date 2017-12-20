memory.usememorydomain("Combined WRAM")

--[[
6 cases:
right char
	2 (bottom)
	20 (middle)
	38 (top)
left char
	11 (bottom)
	29 (middle)
	47 (top)
]]--

while true do
local start_address = 0x03C140 
local blocks = memory.readbyte(0x03C12E)	--number of blocks atm
local block_state = 0
local block_pos = 0
local right_char = memory.readbyte(0x03C138)	--move with a/b
local left_char = memory.readbyte(0x03C139)	--move with up/down

	for i = 0, blocks do
		block_state = memory.readbyte(start_address+(i*4))
		if (block_state == 1) then	--it exists, and is not being carried to next section

			block_pos = memory.readbyte(start_address+(i*4)+1)
			if (block_pos == 2) then
				if (right_char > 0) then joypad.set({B = true}) end
			elseif (block_pos == 20) then 
				if (right_char > 1) then joypad.set({B = true}) else joypad.set({A = true}) end
			elseif (block_pos == 38) then
				if (right_char < 2) then joypad.set({A = true}) end
			elseif (block_pos == 11) then
				if (left_char > 0) then joypad.set({Down = true}) end
			elseif (block_pos == 29) then 
				if (left_char > 1) then joypad.set({Down = true}) else joypad.set({Up = true}) end
			elseif (block_pos == 47) then
				if (left_char < 2) then joypad.set({Up = true}) end
			end
			emu.frameadvance()
		end
	end
	emu.frameadvance()
end
