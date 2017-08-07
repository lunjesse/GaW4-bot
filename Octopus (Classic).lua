memory.usememorydomain("Combined WRAM")
local rightT = {[0]=0x03AACA,[1]=0x03AB46,[2]=0x03ABC2,[3]=0x03AC3E,[4]=0x03ACBA,[5]=0x03ACBA,[6]=0x03ACBA,[7]=0x03ACBA}
local rightL = {[0]=3,[1]=4,[2]=5,[3]=4,[4]=3,[5]=3,[6]=3,[7]=3}
local leftT = {[0]=0x03AACA,[1]=0x03AACA,[2]=0x03AACA,[3]=0x03AB46,[4]=0x03ABC2,[5]=0x03AC3E,[6]=0x03AC3E,[7]=0x03AC3E}
local leftL = {[0]=3,[1]=3,[2]=3,[3]=4,[4]=5,[5]=4,[6]=4,[7]=4}
local state = 0x03A8DA
local loot = 0x03A8E4

local function testTentacle(index,right)
	if right == true then
		if memory.readbyte(rightT[index]) == rightL[index] then
			gui.drawText(3,3,"Right:"..rightT[index].."RightL:"..rightL[index],'RED')
			gui.drawText(3,13,"FALSE: i:"..index.."STATE:"..memory.readbyte(state),'RED')
			emu.frameadvance()
			return false
		elseif memory.readbyte(rightT[index]) == rightL[index]-1 and memory.readbyte(rightT[index]+10) == 2 then
			gui.drawText(3,3,"Right:"..rightT[index].."RightL:"..rightL[index],'RED')
			gui.drawText(3,13,"FALSE: i:"..index.."STATE:"..memory.readbyte(state),'RED')
			emu.frameadvance()
			return false
			end
	else
		if memory.readbyte(leftT[index]) == leftL[index] and index < 7 then
			gui.drawText(3,3,"Left:"..leftT[index].."LeftL:"..leftL[index],'RED')
			gui.drawText(3,13,"FALSE: i:"..index.."STATE:"..memory.readbyte(state),'RED')
			emu.frameadvance()
			return false
		elseif memory.readbyte(leftT[index]) == leftL[index]-1 and memory.readbyte(leftT[index]+10) == 2 and index < 7 then
			gui.drawText(3,3,"Left:"..leftT[index].."LeftL:"..leftL[index],'RED')
			gui.drawText(3,13,"FALSE: i:"..index.."STATE:"..memory.readbyte(state),'RED')
			emu.frameadvance()
			return false
		elseif memory.readbyte(leftT[index]) == leftL[index]-1 and memory.readbyte(leftT[index]+10) == 2 and index == 7 then
			gui.drawText(3,3,"Left:"..leftT[index].."LeftL:"..leftL[index],'RED')
			return true
			end
	end
	return true
end 

while true do
	gui.drawText(160,0,"Stored:"..memory.readbyte(0x03A446),'BLACK')
	gui.drawText(160,10,"Total:"..memory.readbyte(0x03A446)+memory.readbyte(0x03A3C8),'BLACK')
	if memory.readbyte(loot) == 0 or memory.readbyte(loot) == 96 or memory.readbyte(loot) == 128 then
		if memory.readbyte(state) % 2 == 0 and memory.readbyte(state) <= 5 then
			if testTentacle(memory.readbyte(state),true) then
				joypad.set({Right = 1})
			else emu.frameadvance()
			end
		elseif memory.readbyte(state) % 2 == 1 and memory.readbyte(state) <= 5 then
			if testTentacle(memory.readbyte(state),true) then
				joypad.set({A = 1})
			else emu.frameadvance()
			end
		end
	elseif memory.readbyte(loot) == 64 or memory.readbyte(loot) == 192 then
		if memory.readbyte(state) % 2 == 0 and memory.readbyte(state) >= 0 and memory.readbyte(state) < 7 then
			if testTentacle(memory.readbyte(state),false) then
				joypad.set({Up = 1})
			else emu.frameadvance()
			end
		elseif memory.readbyte(state) % 2 == 1 and memory.readbyte(state) >= 0 and memory.readbyte(state) <= 7 then
			if testTentacle(memory.readbyte(state),false) then
				joypad.set({Left = 1})
			else emu.frameadvance()
			end
		end
	end
	emu.frameadvance()
end
