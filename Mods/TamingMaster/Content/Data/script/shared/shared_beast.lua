local ns = require('Albeoris.TamingMaster');

--------------------------------------------------------------------------------
--- Revert to original implementation if the script was reloaded to avoid double hook
--------------------------------------------------------------------------------
if ns.Original.GetTamingTimeCalculator then
	GetTamingTimeCalculator = ns.Original.GetTamingTimeCalculator;
end

--------------------------------------------------------------------------------
--- Calculates the taming time for a beast by applying several modifiers.
--- 
--- The original function starts with a base taming time computed as:
---   1. 10% of the target's HP.
---   2. Adjusts the time based on the level difference between the target and the caster.
---   3. Adds extra time if the target has a loyalty buff (if any buff with TameDurationRatio > 1 is found).
---   4. Reduces the time if the caster possesses the 'MonsterMaster' mastery.
--- Finally, it builds a detailed breakdown of all modifiers and returns both the final time and this info.
---
--- @param 	table 	self 				The caster (should have a 'Lv' field representing its level).
--- @param 	table 	target 				The target creature (must include 'HP' and 'Lv' fields).
--- @param 	table 	ability 			The ability used for taming (unused).
--- @param 	table 	abilityDetailInfo 	Additional details for the ability (unused).
--- @return number	tamingTime 			The final taming time (non-negative).
--- @return table 	info 				A table detailing each modifier applied (each entry contains 'Type', 'Value', and 'ValueType').
--------------------------------------------------------------------------------
ns.Original.GetTamingTimeCalculator = GetTamingTimeCalculator;

--------------------------------------------------------------------------------
--- The modified function calls the original one and also applies the monster's knowledge modifier.
--- The maximum percentage of information level reduces the taming time by a factor that is configurable
--- via game options (defaulting to 75% if no custom value is provided).
--------------------------------------------------------------------------------
GetTamingTimeCalculator = function(self, target, ability, abilityDetailInfo)
	-- Call the original function
	local totalTamingTime, info = ns.Original.GetTamingTimeCalculator(self, target, ability, abilityDetailInfo);
	
	-- Do nothing in case of zero time
	if totalTamingTime == 0 then
		return totalTamingTime, info;
	end
	
	-- Try resolve monster from target
	local monster = ns.TryResolveMonsterByTarget(target);
	if not monster then
		return totalTamingTime, info;
	end
		
	-- Get troublemaker info grade
	local company = GetCompany_Shared(self);
	local tm = company.Troublemaker[monster.OriginalType];
	if not tm then
		return totalTamingTime, info;
	end
	local infoGrade = GetTroublemakerInfoGrade(tm);
	
	if infoGrade == 0 then
		return totalTamingTime, info;
	end
	
	-- Calculate the modifier
	local reductionFraction = ns.CalculateTamingReductionFraction(infoGrade);
	local addValue = math.floor(-totalTamingTime * reductionFraction)  -- This is the negative delta.
	totalTamingTime = totalTamingTime + addValue;
	totalTamingTime = math.max(totalTamingTime, 0);
	
	if info[1] and info[1].Type == 'TamingTime' then
		info[1].Value = totalTamingTime
	end
	
	-- Add bonus info
	table.insert(info, { Type = 'Albeoris_TamingMaster_CollectedInformation', Value = addValue, ValueType = 'Formula' });
	
	return totalTamingTime, info;
end