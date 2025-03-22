local ns = require('Albeoris.TamingMaster');

--------------------------------------------------------------------------------
--- Revert to original implementation if the script was reloaded to avoid double hook
--------------------------------------------------------------------------------
if ns.Original.FillTroublemakerDetails then
	FillTroublemakerDetails = ns.Original.FillTroublemakerDetails;
end

--------------------------------------------------------------------------------
--- Fills the TroubleMaker UI with detailed monster information.
--- It sets up various UI components such as stats, abilities, equipment, items, missions, and synergy info.
---
--- @param table	target  	The UI target element for displaying monster details.
--- @param number	monID   	The identifier of the monster from the current list.
--- @param table	tm      	Table containing troublemaker data (e.g., Exp, MaxExp, BonusItem, etc.).
--- @param table	gradeMon	(optional) Table with upgraded monster details, if available.
--------------------------------------------------------------------------------
ns.Original.FillTroublemakerDetails = FillTroublemakerDetails

--------------------------------------------------------------------------------
--- Updates the TroubleMaker UI details for a monster and adds taming time reduction info for beasts.
--- First, it calls the original FillTroublemakerDetailsOriginal method to set up the base UI.
--- Then it retrieves the current monster from the TroubleMaker list.
--- For beast monsters, it iterates through 7 markers (representing different information grades).
--- For each marker (grade i), it calculates the taming time reduction percentage via CalculateTamingReductionFraction(i),
--- converts it to an integer percentage, and appends a formatted message (e.g., "Reduces taming time by X %") to the marker's tooltip content.
--------------------------------------------------------------------------------
FillTroublemakerDetails = function(target, monID, tm, gradeMon)
	
	-- Call the original method
	ns.Original.FillTroublemakerDetails(target, monID, tm, gradeMon);
	
	local win = GetRootLayout('Troublemaker', false);
	
	-- Get current monster
	local currentList = win:getUserData('CurrentTMList');
	local mon = currentList[monID];
	
	-- Skip if it's not a beast
	if mon.Object.Race.name ~= 'Beast' then
		return;
	end
	
	local infoGrade = GetTroublemakerInfoGrade(tm);	
	
	local troublemakerWin = win:getChild('Troublemaker');
	local troublemakerDetailWin = troublemakerWin:getChild('TroublemakerDetail');
		
	-- Update marker tooltips
	for i = 1, 7 do
		local curMarker = troublemakerDetailWin:getChild('Marker'..i);
		local tooltipContent = curMarker:getUserData('Content');
		local reductionPercent = math.floor(ns.CalculateTamingReductionFraction(i) * 100);

		if reductionPercent ~= 0 then
			local color = infoGrade < i and 'FFCCCCCC' or 'FF00FF00';
	
			local format = GuideMessage('Albeoris_TamingMaster_InformationGradeRewardFormat');
			local newLine = string.format(format, reductionPercent)
			tooltipContent = string.format("%s\n[colour='%s']%s", tooltipContent, color, newLine);
			
			curMarker:setUserData('Content', tooltipContent);
		end
	end
end