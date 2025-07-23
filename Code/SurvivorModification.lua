local function debug(msg)
	print("[Force Skills and Traits] "..msg)
end

local function ApplySkillLevelChanges(survivor, skill_id, action, value)
	if action and action ~= "Don't change" then
		local current_level = survivor:GetSkillLevel(skill_id)
		
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

local function ApplySkillInclinationChanges(survivor, skill_id, inclination)
	if inclination and inclination ~= "Don't change" then
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

local function ApplyTraitChanges(survivor, trait_id, action)	
	if action == "Add" then
		if not survivor:HasTrait(trait_id) then
			survivor:SetTrait(trait_id, true, "forced")
		end
	elseif action == "Remove" then
		if survivor:HasTrait(trait_id) then
			survivor:SetTrait(trait_id, false, "forced")
		end
	end
end

local function ApplyModificationsToSurvivor(survivor)
	-- debug("ApplyModificationsToSurvivor("..tostring(survivor.id)..")")
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

local function ApplyModifications()
	-- debug("ApplyModifications() Executing")

	-- Determine which survivors to modify
	local apply_to = CurrentModOptions.ApplyTo
	local targets = {}
	
	if not apply_to then
		return
	elseif apply_to == "*All Survivors*" then
		targets = AllSurvivors
	else
		-- Find specific survivor by name
		for _, survivor in ipairs(AllSurvivors) do
			local name = _InternalTranslate(survivor.FirstName).." ".._InternalTranslate(survivor.LastName)
			if name == apply_to then
				table.insert(targets, survivor)
				break
			end
		end
		
		-- Log warning if survivor not found
		if #targets == 0 then
			print("[ForceSkillsAndTraits] Warning: Survivor '" .. apply_to .. "' not found")
		end
	end

	-- Apply modifications to selected survivors
	for _, survivor in ipairs(targets) do
		if not survivor:IsDead() then
			ApplyModificationsToSurvivor(survivor)
		end
	end
end

function OnMsg.LoadGame()
	if CurrentModOptions.ApplyWhen == "On Game Load" then
		ApplyModifications()
	end
end

function OnMsg.PreHumanInit()
	if CurrentModOptions.ApplyWhen == "Survivor Joins & new game" then
		ApplyModifications()
	end
end