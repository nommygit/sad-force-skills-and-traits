local function ApplySkillChanges(survivor, skill_id)
	local action = CurrentModOptions[skill_id .. "Action"]
	local value = CurrentModOptions[skill_id .. "Value"]
	local inclination = CurrentModOptions[skill_id .. "Inclination"]
	
	-- Apply skill level changes
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
	
	-- Apply inclination changes
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

local function ApplyTraitChanges(survivor, trait_id)
	-- local action = CurrentModOptions[trait_id]
	
	-- if action == "Add" then
	-- 	if not survivor:HasTrait(trait_id) then
	-- 		survivor:AddTrait(trait_id)
	-- 	end
	-- elseif action == "Remove" then
	-- 	if survivor:HasTrait(trait_id) then
	-- 		survivor:RemoveTrait(trait_id)
	-- 	end
	-- end
end

local function ApplyModifications(survivor)
	-- Apply skill modifications
	ForEachPreset("Skill", function(skill)
		ApplySkillChanges(survivor, skill.id)
	end)
	
	-- Apply trait modifications
	-- ForEachPreset("Trait", function(trait)
	-- 	ApplyTraitChanges(survivor, trait.id)
	-- end)
end

function OnMsg.LoadGame()
	-- Check if we should apply modifications
	local apply_when = CurrentModOptions.ApplyWhen
	if apply_when ~= "On Game Load" then
		return
	end

	-- Determine which survivors to modify
	local apply_to = CurrentModOptions.ApplyTo
	local targets = {}
	
	if not apply_to or apply_to == "Nobody (disable mod)" then
		return
	elseif apply_to == "All Survivors" then
		targets = AllSurvivors
	else
		-- Find specific survivor by name
		for _, survivor in ipairs(AllSurvivors) do
			if survivor.name == apply_to then
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
			ApplyModifications(survivor)
		end
	end
end