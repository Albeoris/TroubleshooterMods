--------------------------------------------------------------------------------
--- Namespaces Initialization
--------------------------------------------------------------------------------
local Albeoris = Albeoris or {};
Albeoris.TamingMaster = Albeoris.TamingMaster or {};
Albeoris.TamingMaster.Original = Albeoris.TamingMaster.Original or {};

--------------------------------------------------------------------------------
--- Calculates the taming time reduction fraction based on the given info grade.
---
--- This function determines how much the taming time should be reduced by using a 
--- predefined ratio table (mapping info grade to a factor) and a global modifier limit.
--- The modifier limit is read from the game options (defaulting to 75% if not provided).
---
--- @param number infoGrade
---        A numerical grade (between 0 and 7) representing the information level about a beast.
---        Higher values indicate a greater reduction in taming time.
---
--- @return number
---         The reduction fraction as a decimal (e.g., 0.75 means a 75% reduction applied).
--------------------------------------------------------------------------------
Albeoris.TamingMaster.CalculateTamingReductionFraction = function(infoGrade)
	
	-- Not available on the server side 
	-- local modifierLimit = GetOption().Gameplay.Albeoris_TamingMaster_InformationInfluencesTamingPecent or 75; -- default value if not provided
	
	local modifierLimit = 75;
	local gradeToRatio = {
        [0] = 0.00,
        [1] = 0.01,
        [2] = 0.05,
        [3] = 0.15,
        [4] = 0.30,
        [5] = 0.50,
        [6] = 0.75,
        [7] = 1.00,
    };
    local factor = gradeToRatio[infoGrade] or 0.00;
	return factor * modifierLimit / 100;
end

--------------------------------------------------------------------------------
--- Attempts to resolve the monster class for a given target object.
---
--- This function checks whether the target has a defined 'MonsterType' property.
--- If so, it fetches the corresponding monster class from the global class list.
--- Otherwise, it tries to resolve the monster class using the target's beast type.
---
--- @param table target
---        The target object for which to resolve the monster class.
---
--- @return table|nil
---         The monster class if successfully resolved; otherwise, nil.
--------------------------------------------------------------------------------
Albeoris.TamingMaster.TryResolveMonsterByTarget = function(target)
    local targetMonType = GetInstantProperty(target, 'MonsterType');
	
    if targetMonType then
	    return GetClassList('Monster')[targetMonType];
    end
	
	local targetBeastTypeCls = GetBeastTypeClassFromObject(target);
	if targetBeastTypeCls then
	    return targetBeastTypeCls.Monster;
    end

	return nil;
end

package.loaded["Albeoris.TamingMaster"] = Albeoris.TamingMaster;