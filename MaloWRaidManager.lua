
-- Global variables
lastSwap1 = "none";
lastSwap2 = "none";

bloodlustGroups = {}

-- Main
SlashCmdList["MRMCOMMAND"] = function(msg)
	local arguments = mrm_SplitString(msg)
	local command = arguments[1]
	table.remove(arguments, 1)
	if command == "swap" then
		local player1Name = arguments[1]
		local player2Name = arguments[2]
		mrm_Swap(player1Name, player2Name)
		lastSwap1 = player1Name
		lastSwap2 = player2Name
		mrm_Whisper("You have been swapped, do your thing!", player1Name);
		mrm_Print("MRM: Swapped " .. player1Name .. " with " .. player2Name)
	elseif command == "blgroup" then
		local group = arguments[1]
		table.remove(arguments, 1)
		mrm_BloodlustGroup(group, arguments)
	elseif command == "swapback" then
		mrm_Swap(lastSwap1, lastSwap2)
		mrm_Print("MRM: Swapped back " .. lastSwap1 .. " with " .. lastSwap2)
	elseif command == "swapbackafterbl" then
		if mrm_HasBuff(lastSwap1, "Bloodlust") then
			mrm_Swap(lastSwap1, lastSwap2)
			mrm_Print("MRM: Bloodlust present, swapped back " .. lastSwap1 .. " with " .. lastSwap2)
		else 
			mrm_Print("MRM: Bloodlust not present on " .. lastSwap1 .. " aborting swap back")
		end
	else
		mrm_Print("MRM: Unrecognized command: " .. command)
	end
end 
SLASH_MRMCOMMAND1 = "/mrm";

function mrm_Swap(player1Name, player2Name)
	local player1Index, player1SubGroup = mrm_GetRaidIndexAndSubGroupForUnitName(player1Name)
	local player2Index, player2SubGroup = mrm_GetRaidIndexAndSubGroupForUnitName(player2Name)
	SetRaidSubgroup(player1Index, 8)
	SetRaidSubgroup(player2Index, player1SubGroup)
	SetRaidSubgroup(player1Index, player2SubGroup)
end

function mrm_HasBuff(playerName, buff)
	local playerIndex = mrm_GetRaidIndexAndSubGroupForUnitName(playerName)
	for i = 1, 32 do
		local d = UnitBuff("raid" .. playerIndex, i)
		if d and d == buff then
			return true
		end
	end
	return false
end

function mrm_GetRaidIndexAndSubGroupForUnitName(playerName)
	local numberOfRaidMembers = GetNumRaidMembers()
	for i = 1, numberOfRaidMembers do
		local name, _, subGroup = GetRaidRosterInfo(i)
		if string.lower(name) == playerName then
			return i, subGroup
		end
	end
	mrm_Print("MRM: Error, couldn't find player " .. playerName .. " in your raid")
	return nil;
end

function mrm_BloodlustGroup(group, players)
	if bloodlustGroups[group] ~= nil then
		for _, player in pairs(players) do
			if mrm_HasBuff(player, "Bloodlust") then
				for _, player in pairs(players) do 
					local playerIndex = mrm_GetRaidIndexAndSubGroupForUnitName(player)
					SetRaidSubgroup(playerIndex, bloodlustGroups[group][player])
				end
				bloodlustGroups[group] = nil
				mrm_Print("MRM: Moved the players in group " .. group .. " back to their original groups after getting Bloodlust") 
				return
			end
		end
		mrm_Print("MRM: Bloodlust not present on " .. players .. " aborting swap back") 
		return
	end
	
	bloodlustGroups[group] = {}
	for _, player in pairs(players) do 
		local playerIndex, playerSubGroup = mrm_GetRaidIndexAndSubGroupForUnitName(player)
		bloodlustGroups[group][player] = playerSubGroup
		SetRaidSubgroup(playerIndex, group)
	end
	mrm_Whisper("Bloodlust group created, POP IT!", players[1]);
	mrm_Print("MRM: Moved " .. players .. " to group " .. group .. " for Bloodlust") 
end


function mrm_SplitString(s)
	t = {}
	index = 1
	for value in string.gmatch(s, "%S+") do 
		t[index] = string.lower(value)
		index = index + 1
	end
	return t
end

-- Prints message in chatbox
function mrm_Print(msg)
	ChatFrame1:AddMessage(msg);
end

-- Prints message in chatbox
function mrm_Whisper(msg, player)
	SendChatMessage(msg, "WHISPER", nil, player);
end



