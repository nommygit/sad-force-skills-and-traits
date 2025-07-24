-- Logging helper functions
local function logWarning(message)
	print("[Force Skills and Traits] WARNING: " .. message)
end

local function logError(message)
	print("[Force Skills and Traits] ERROR: " .. message)
end

--[[
	Applies skill level changes to a survivor
]]
local function ApplySkillLevelChanges(survivor, skill_id, action, value)
	if not survivor then
		logError("Invalid survivor in ApplySkillLevelChanges")
		return
	end
	
	if type(skill_id) ~= "string" or skill_id == "" then
		logError("Invalid skill_id in ApplySkillLevelChanges")
		return
	end

	if action and action ~= "Don't change" then
		if action ~= "Set to:" and action ~= "Set to Minimum of:" and action ~= "Set to Maximum of:" then
			logWarning("Unknown action in ApplySkillLevelChanges: " .. tostring(action))
			return
		end
		
		if type(value) ~= "number" then
			logWarning("Invalid value type in ApplySkillLevelChanges for action: " .. action)
			return
		end
		
		local current_level = survivor:GetSkillLevel(skill_id)
		if not current_level then
			logWarning("Failed to get current_level ApplySkillLevelChanges for survivor.id, skill_id: " .. survivor.id .. ", " .. skill_id)
		elseif type(current_level) ~= "number" then
			logWarning("Invalid current_level type in ApplySkillLevelChanges for action: " .. action)
			return
		end
		
		if action == "Set to:" then
			survivor:SetSkillLevel(skill_id, value, "silent")
		elseif action == "Set to Minimum of:" then
			if current_level < value then
				survivor:SetSkillLevel(skill_id, value, "silent")
			end
		elseif action == "Set to Maximum of:" then
			if current_level > value then
				survivor:SetSkillLevel(skill_id, value, "silent")
			end
		end
	end
end

--[[
	Applies skill inclination changes to a survivor
]]
local function ApplySkillInclinationChanges(survivor, skill_id, inclination)
	if not survivor then
		logError("Invalid survivor in ApplySkillInclinationChanges")
		return
	end
	
	if type(skill_id) ~= "string" or skill_id == "" then
		logError("Invalid skill_id in ApplySkillInclinationChanges")
		return
	end

	if inclination and inclination ~= "Don't change" then
		local validInclinations = {
			["Set to Interested"] = true,
			["Set to Normal"] = true,
			["Set to Indifferent"] = true,
			["Change Indifferent to Normal"] = true,
			["Change Interested to Normal"] = true
		}
		
		if not validInclinations[inclination] then
			logWarning("Unknown inclination in ApplySkillInclinationChanges: " .. tostring(inclination))
			return
		end
		
		local current_inclination = survivor:GetSkillInclination(skill_id)
		
		if inclination == "Set to Interested" then
			survivor:SetSkillInclination(skill_id, "Interested")
		elseif inclination == "Set to Normal" then
			survivor:SetSkillInclination(skill_id, "Normal")
		elseif inclination == "Set to Indifferent" then
			survivor:SetSkillInclination(skill_id, "Indifferent")
		elseif inclination == "Change Indifferent to Normal" then
			if current_inclination == "Indifferent" then
				survivor:SetSkillInclination(skill_id, "Normal")
			end
		elseif inclination == "Change Interested to Normal" then
			if current_inclination == "Interested" then
				survivor:SetSkillInclination(skill_id, "Normal")
			end
		end
	end
end

--[[
	Applies all skill changes for a specific skill
]]
local function ApplySkillChanges(survivor, skill_id)
	local action, value, inclination

	-- Apply any *All Skills* options first
	action = CurrentModOptions["AllSkillsAction"]
	value = CurrentModOptions["AllSkillsValue"]
	inclination = CurrentModOptions["AllSkillsInclination"]
	ApplySkillLevelChanges(survivor, skill_id, action, value)
	ApplySkillInclinationChanges(survivor, skill_id, inclination)

	-- Apply any individual skill options
	action = CurrentModOptions[skill_id .. "Action"]
	value = CurrentModOptions[skill_id .. "Value"]
	inclination = CurrentModOptions[skill_id .. "Inclination"]
	ApplySkillLevelChanges(survivor, skill_id, action, value)
	ApplySkillInclinationChanges(survivor, skill_id, inclination)
end

--[[
	Applies trait changes to a survivor
]]
local function ApplyTraitChanges(survivor, trait_id, action)	
	if not survivor then
		logError("Invalid survivor in ApplyTraitChanges")
		return
	end
	
	if type(trait_id) ~= "string" or trait_id == "" then
		logError("Invalid trait_id in ApplyTraitChanges")
		return
	end

	if action == "Add" then
		if not survivor:HasTrait(trait_id) then
			survivor:SetTrait(trait_id, true, "forced")
		end
	elseif action == "Remove" then
		if survivor:HasTrait(trait_id) then
			survivor:SetTrait(trait_id, false, "forced")
		end
	elseif action and action ~= "Don't change" then
		logWarning("Unknown action in ApplyTraitChanges: " .. tostring(action))
	end
end

--[[
	Applies all modifications to a single survivor
]]
local function ApplyModificationsToSurvivor(survivor)
	if not survivor then
		logError("Invalid survivor in ApplyModificationsToSurvivor")
		return
	end
	
	-- Apply skill modifications
	ForEachPreset("Skill", function(skill)
		ApplySkillChanges(survivor, skill.id)
	end)
	
	-- Apply trait modifications
	local allTraitsAction = CurrentModOptions["AllTraitsAction"]
	ForEachPreset("Trait", function(trait)
		local trait_id = trait.id

		-- Apply *All Traits* changes first
		ApplyTraitChanges(survivor, trait_id, allTraitsAction)

		-- Apply individual trait changes
		local action = CurrentModOptions[trait_id]
		ApplyTraitChanges(survivor, trait_id, action)
	end)
end

--[[
	Main function to apply modifications to selected survivors
]]
local function ApplyModifications()
	-- Determine which survivors to modify
	local apply_to = CurrentModOptions.ApplyTo
	local targets = {}
	
	if not apply_to then
		logWarning("ApplyTo option not set")
		return
	elseif apply_to == "*All Survivors*" then
		if not AllSurvivors or #AllSurvivors == 0 then
			logWarning("No survivors found for modification")
			return
		end
		targets = AllSurvivors
	else
		-- Find specific survivor by name
		local found = false
		for _, survivor in ipairs(AllSurvivors) do
			local name = _InternalTranslate(survivor.FirstName).." ".._InternalTranslate(survivor.LastName)
			if name == apply_to then
				table.insert(targets, survivor)
				found = true
				break
			end
		end
		
		-- Log warning if survivor not found
		if not found then
			logWarning("Survivor '" .. apply_to .. "' not found")
		end
	end

	-- Apply modifications to selected survivors
	for _, survivor in ipairs(targets) do
		if not survivor:IsDead() then
			ApplyModificationsToSurvivor(survivor)
		end
	end
end

--[[
	Game load handler
]]
function OnMsg.LoadGame()
	if CurrentModOptions.ApplyWhen == "On Game Load" then
		-- Delayed execution wrapper required for code to work
		CreateGameTimeThread(function()
			Sleep(100)  -- Allow colony initialization
			ApplyModifications()
		end)
	end
end

--[[
	New survivor initialization handler
]]
function OnMsg.PreHumanInit()
	if CurrentModOptions.ApplyWhen == "Survivor Joins & new game" then
		-- Delayed execution wrapper required for code to work
		CreateGameTimeThread(function()
			Sleep(100)  -- Allow colony initialization
			ApplyModifications()
		end)
	end
end