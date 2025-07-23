-- Logging helper functions
local function logWarning(message)
	print("[Force Skills and Traits] WARNING: " .. message)
end

local function logError(message)
	print("[Force Skills and Traits] ERROR: " .. message)
end

--[[
	Returns a sorted table array containing the full names of all defined survivors (CharacterDefs)
]]
local function SurvivorNamesArray()
	local names = {}
		
	ForEachPreset("CharacterDef", function(unit, group) 
		if unit and unit.FirstName and unit.LastName then
			table.insert(names, _InternalTranslate(unit.FirstName).." ".._InternalTranslate(unit.LastName))
		end
	end)
	
	table.sort(names, function(a, b)
		return a < b
	end)
	
	return names
end

--[[
	Appends survivor names to a table
]]
local function AppendSurvivorNamesArray(tbl)
	if type(tbl) ~= "table" then
		logError("AppendSurvivorNamesArray: Invalid table parameter")
		return {}
	end
	
	local survivorNames = SurvivorNamesArray() or {}
	for _, name in ipairs(survivorNames) do
		table.insert(tbl, name)
	end
	return tbl
end

--[[
	Creates choice list for "Apply To" option
	@return table: Array containing "*All Survivors*" and survivor names
]]
local function FSaT_OptionApplyToChoiceList()
	return AppendSurvivorNamesArray({"*All Survivors*"})
end

--[[
	Recursively replaces placeholders in a string or table template
	@param template string|table: Template with {$key} placeholders
	@param values table: Key-value substitutions
	@return string|table: Template with substitutions applied
]]
local function Substitute(template, values)
	if type(template) == "string" then
		-- Handle special substitution for survivor list
		if template == "{$FSaT_OptionApplyToChoiceList()}" then
			return FSaT_OptionApplyToChoiceList()
		end
		
		if not values or next(values) == nil then 
			return template 
		end
		
		return template:gsub("{%$(.-)}", function(k)
			local v = values[k]
			if type(v) == "table" then 
				return table.concat(v, ", ") 
			end
			return tostring(v or "")
		end)
	elseif type(template) == "table" then
		local out = {}
		for k, v in pairs(template) do
			out[k] = Substitute(v, values)
		end
		return out
	else
		return template
	end
end

--[[
	Performs deep copy of a table
	@param orig any: Value to copy
	@param copies table: Internal tracker for circular references
	@return any: Deep copy of original value
]]
local function DeepCopy(orig, copies)
	-- Handle non-table values
	if type(orig) ~= "table" then 
		return orig 
	end
	
	-- Initialize copies tracker
	copies = copies or {}
	
	-- Check for circular references
	if copies[orig] then 
		return copies[orig] 
	end
	
	-- Create new table and track it
	local copy = {}
	copies[orig] = copy

	-- Recursively copy keys and values
	for k, v in next, orig, nil do
		copy[DeepCopy(k, copies)] = DeepCopy(v, copies)
	end

	-- Preserve metatable
	return setmetatable(copy, getmetatable(orig))
end

--[[
	Creates mod items from a template
	@param template table: Array of PlaceObj definitions
	@return table: Array of created PlaceObj instances
]]
local function CreateModItemsFromTemplate(template)
	if type(template) ~= "table" then
		logError("CreateModItemsFromTemplate: Invalid template")
		return {}
	end
	
	local items = {}
	for _, item_def in ipairs(template) do
		if item_def and item_def.class and item_def.args then
			table.insert(items, PlaceObj(item_def.class, item_def.args))
		else
			logWarning("CreateModItemsFromTemplate: Invalid item definition")
		end
	end
	return items
end

--[[
	Appends substituted template items to destination table
	@param dest table: Destination array
	@param template table: Template to process
	@param substituteValues table: Substitution values
	@return table: Modified destination table
]]
local function GenerateAndAppendModItems(dest, template, substituteValues)
	if type(dest) ~= "table" then
		logError("GenerateAndAppendModItems: Invalid dest parameter")
		return {}
	end
	
	if type(template) ~= "table" then
		logError("GenerateAndAppendModItems: Invalid template")
		return dest
	end
	
	-- Deep copy and substitute template
	local templateCopy = Substitute(DeepCopy(template), substituteValues)
	
	-- Instantiate mod items
	local items = CreateModItemsFromTemplate(templateCopy)
	
	-- Add mod items to dest table
	for i = 1, #items do
		dest[#dest + 1] = items[i]
	end
	
	return dest
end

--[[
	Returns sorted skills array
]]
local function SortedSkills()
	local sortedSkills = {}
	for _, skill in pairs(Skills) do
		table.insert(sortedSkills, skill)
	end
	table.sort(sortedSkills, function(a, b)
		return a.SortKey < b.SortKey
	end)
	return sortedSkills
end

--[[
	Returns sorted visible traits
	@return table: Traits sorted by DisplayName, excluding hidden and special traits
]]
local function SortedTraits()
	local sortedTraits = {}
	for _, trait in pairs(Traits) do
		-- Exclude hidden and special traits
		if (not trait.HiddenTrait) and trait.group ~= "Special and events" then
			table.insert(sortedTraits, trait)
		end
	end
	table.sort(sortedTraits, function(a, b)
		return _InternalTranslate(a.DisplayName) < _InternalTranslate(b.DisplayName)
	end)
	return sortedTraits
end

--[[
	Builds enhanced trait description
	@param trait table: Trait definition
	@return string: Enhanced description with incompatibility info
]]
local function BuildTraitDescription(trait)
	if not trait then
		logWarning("BuildTraitDescription: Invalid trait")
		return ""
	end
	
	local description = _InternalTranslate(trait.Description)
	
	-- Add incompatibility information if available
	if trait.Incompatible and #trait.Incompatible > 0 then
		description = description..".  Incompatible with: "
		local incompatible = trait.Incompatible
		local addComma = false
		for i, id in ipairs(incompatible) do
			local incompatibleTrait = Traits[id]
			if incompatibleTrait and incompatibleTrait.DisplayName then
				if addComma then description = description..", " end
				description = description.._InternalTranslate(incompatibleTrait.DisplayName)
				addComma = true
			end
		end
	end
	return description
end

--[[
	Main item construction function
	@return table: Array of PlaceObj instances representing mod options and any other items
]]
function FSaT_BuildItems()
	-- Check required global exists
	if not FSaT_Templates then
		logError("FSaT_Templates not defined")
		return {}
	end
	
	local items = {}
	
	-- Build core options
	GenerateAndAppendModItems(items, FSaT_Templates.ModCodeItems)
	GenerateAndAppendModItems(items, FSaT_Templates.ApplyOptions)
	GenerateAndAppendModItems(items, FSaT_Templates.DisplayFormattingGapOption, {id=1})
	GenerateAndAppendModItems(items, FSaT_Templates.AllSkillsOptions)
	
	-- Add skill options
	local sortedSkills = SortedSkills()
	for _, skill in pairs(sortedSkills) do
		if skill and skill.id and skill.DisplayName then
			GenerateAndAppendModItems(items, FSaT_Templates.SkillOptions, {
				id = skill.id,
				DisplayName = _InternalTranslate(skill.DisplayName),
				Description = _InternalTranslate(skill.Description)
			})
		end
	end
	
	-- Add formatting gap
	GenerateAndAppendModItems(items, FSaT_Templates.DisplayFormattingGapOption, {id=2})
	GenerateAndAppendModItems(items, FSaT_Templates.AllTraitsOptions)
	
	-- Add trait options
	local sortedTraits = SortedTraits()
	for _, trait in pairs(sortedTraits) do
		if trait and trait.id and trait.DisplayName then
			GenerateAndAppendModItems(items, FSaT_Templates.TraitOptions, {
				id = trait.id,
				DisplayName = _InternalTranslate(trait.DisplayName),
				Description = BuildTraitDescription(trait)
			})
		end
	end
	
	return items
end