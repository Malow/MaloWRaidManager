
-- Global variables
lastSwap1 = "none";
lastSwap2 = "none";

-- Main
SlashCmdList["MRMCOMMAND"] = function(msg)
	local commands = mrm_SplitString(msg)
	commands[1] = string.lower(commands[1])
	if commands[1] == "swap" then
		local player1Name = string.lower(commands[2]);
		local player2Name = string.lower(commands[3]);
		mrm_Swap(player1Name, player2Name)
		lastSwap1 = player1Name;
		lastSwap2 = player2Name;
	end
	if commands[1] == "swapback" then
		mrm_Swap(lastSwap1, lastSwap2)
	end
	if commands[1] == "swapbackafterbl" then
		if mrm_HasBuff(lastSwap1, "Bloodlust") then
			mrm_Swap(lastSwap1, lastSwap2)
		end
	end
end 
SLASH_MRMCOMMAND1 = "/mrm";

function mrm_Swap(player1Name, player2Name)
	local player1Index, player1SubGroup = mrm_GetRaidIndexAndSubGroupForUnitName(player1Name);
	local player2Index, player2SubGroup = mrm_GetRaidIndexAndSubGroupForUnitName(player2Name);
	SetRaidSubgroup(player1Index, 8);
	SetRaidSubgroup(player2Index, player1SubGroup);
	SetRaidSubgroup(player1Index, player2SubGroup);
end

function mrm_HasBuff(playerName, buff)
	local playerIndex = mrm_GetRaidIndexAndSubGroupForUnitName(playerName);
	for i = 1, 32 do
		local d = UnitBuff("raid" .. playerIndex, i);
		if d and d == buff then
			return true;
		end
	end
	return false;
end

function mrm_GetRaidIndexAndSubGroupForUnitName(playerName)
	local numberOfRaidMembers = GetNumRaidMembers();
	for i = 1, numberOfRaidMembers do
		local name, _, subGroup = GetRaidRosterInfo(i);
		if string.lower(name) == playerName then
			return i, subGroup;
		end
	end
end

function mrm_SplitString(s)
	t = { };
	index = 1;
	for value in string.gmatch(s, "%S+") do 
		t[index] = value;
		index = index + 1;
	end
	return t;
end




