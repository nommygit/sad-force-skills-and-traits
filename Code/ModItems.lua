-- Returns a table array containing the full names of all defined survivors (CharacterDefs)
local function FSaT_SurvivorNamesArray()
	local names = {}
	ForEachPreset("CharacterDef", function(unit, group) 
		table.insert(names, _InternalTranslate(unit.FirstName).." ".._InternalTranslate(unit.LastName))
	end)
	return names
end

-- Returns a table which is tbl with survivor names added to the end
local function FSaT_AppendSurvivorNamesArray(tbl)
	local survivorNames = FSaT_SurvivorNamesArray() or {}
	for _, name in ipairs(survivorNames) do
		table.insert(tbl, name)
	end
	return tbl
end

-- 
function FSaT_OptionApplyToChoiceList()
	return FSaT_AppendSurvivorNamesArray({"*All Survivors*"})
end

--[[
Substitute(template, values)

Recursively replaces placeholders in a string or table template using a values table.

Arguments:
	template (string or table): A string or nested table containing placeholders
		in the format "${key}" to be replaced.
	values (table, optional): A key–value table containing substitutions. Each key replaces
		occurrences of "${key}" in strings within the template. If nil or empty, the template is returned unchanged.

Returns:
	A new string or table with all matching placeholders replaced.

Notes:
	- If `values` is nil or empty, the original template is returned unchanged.
	- Subtables are processed recursively.
	- If a value is a table, it is joined with ", ".
	- Non-matching keys are replaced with an empty string.

Example:
	local template = {
		title = "Welcome, ${user}!",
		options = { "Option: ${opt1}", "Option: ${opt2}" }
	}
	local values = { user = "Alex", opt1 = "A", opt2 = "B" }
	local result = Substitute(template, values)
]]
local function Substitute(template, values)
	if type(template) == "string" then
		if template == "{$FSaT_OptionApplyToChoiceList()}" then
			return FSaT_OptionApplyToChoiceList()
		end
		
		if not values or next(values) == nil then 
			return template 
		end
		
		return template:gsub("%${(.-)}", function(k)
			local v = values[k]
			if type(v) == "table" then 
				return table.concat(v, ", ") 
			end
			return tostring(v or "")
		end)
	elseif type(template) == "table" then
		local out = {}
		for k, v in pairs(template) do
			-- Recursively process all table elements
			out[k] = Substitute(v, values)
		end
		return out
	else
		return template
	end
end

--[[ 
DeepCopy(orig, copies)

Performs a deep copy of a table, preserving nested structures, keys, values, and metatables. 
Supports recursive and self-referencing tables safely.

Arguments:
	orig (any): The value to copy. If not a table, it's returned as-is.
	copies (table, optional): Internal table to track already-copied tables. 
		Used to handle circular references and shared references correctly.

Returns:
	A new deep-copied version of the input `orig`.

Notes:
	- Handles circular references.
	- Preserves metatables with setmetatable().
	- Table keys and values are deep copied recursively.
	- Non-table values (numbers, strings, booleans, etc.) are returned unchanged.
	- Shared references in the original table will remain shared in the copy.
]]
local function DeepCopy(orig, copies)
	copies = copies or {}
	if type(orig) ~= "table" then return orig end
	if copies[orig] then return copies[orig] end

	local copy = {}
	copies[orig] = copy

	for k, v in next, orig, nil do
		copy[DeepCopy(k, copies)] = DeepCopy(v, copies)
	end

	return setmetatable(copy, getmetatable(orig))
end

--[[
CreateModItemsFromTemplate(template)

Instantiates mod items from a template of PlaceObj definitions.

Returns:
	table array: a list of PlaceObj instances (like the mod editor would create).
]]
local function CreateModItemsFromTemplate(template)
	local items = {}
	for _, item_def in ipairs(template) do
		table.insert(items, PlaceObj(item_def.class, item_def.args))
	end
	return items
end

--[[
GenerateAndAppendModItems(dest, template, substituteValues)

Appends a substituted copy of a template into a destination array.

Arguments:
	dest (table): Array‑style table to receive new entries.
	template (table): Array of PlaceObj–style entries with "${…}" placeholders.
	substituteValues (table): Key–value map for placeholder replacement.

Behavior:
	1. Deep‑copies `template` (preserving metatables and avoiding shared state).
	2. Runs `Substitute()` on the copy to replace all placeholders.
	3. Uses `table.move()` to append every element from the substituted copy into `dest`.

Returns:
	The modified `dest` table (for chaining).
--]]
local function GenerateAndAppendModItems(dest, template, substituteValues)
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

-- Returns array table of Skills sorted by SortKey
local function SortedSkills()
	sortedSkills = {}
	for _, skill in pairs(Skills) do
		table.insert(sortedSkills, skill)
	end
	table.sort(sortedSkills, function(a, b)
		return a.SortKey < b.SortKey
	end)
	return sortedSkills
end

-- Returns array table of Traits sorted by DisplayName excluding hidden and 'Special and events' traits
local function SortedTraits()
	sortedTraits = {}
	for _, trait in pairs(Traits) do
		-- Don't include hidden or 'Special and events' traits  
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
FSaT_BuildItems()

Constructs and returns a sequenced list of mod‑option objects by:
  1. Instantiating core templates (ModCodeItems, ApplyOptions)
  2. Inserting formatting gaps
  3. Generating entries for every loaded skill (with translated names and descriptions)
  4. Inserting a second formatting gap
  5. Generating entries for every visible trait (excluding hidden or “Special and events”)

Usage:
	-- in items.lua
	return FSaT_BuildItems()

Returns:
	An array of PlaceObj instances representing all mod options in order.
]]
function FSaT_BuildItems()
	items = {}
	GenerateAndAppendModItems(items, FSaT_Templates.ModCodeItems)
	GenerateAndAppendModItems(items, FSaT_Templates.ApplyOptions)
	GenerateAndAppendModItems(items, FSaT_Templates.DisplayFormattingGapOption, {id=1})
	GenerateAndAppendModItems(items, FSaT_Templates.AllSkillsOptions)
	sortedSkills = SortedSkills()
	for _, skill in pairs(sortedSkills) do
		GenerateAndAppendModItems(items, FSaT_Templates.SkillOptions, {
			id = skill.id,
			DisplayName = _InternalTranslate(skill.DisplayName),
			Description = _InternalTranslate(skill.Description)
		})
	end
	GenerateAndAppendModItems(items, FSaT_Templates.DisplayFormattingGapOption, {id=2})
	GenerateAndAppendModItems(items, FSaT_Templates.AllTraitsOptions)
	sortedTraits = SortedTraits()
	for _, trait in pairs(sortedTraits) do
		GenerateAndAppendModItems(items, FSaT_Templates.TraitOptions, {
			id = trait.id,
			DisplayName = _InternalTranslate(trait.DisplayName),
			Description = _InternalTranslate(trait.Description)
		})
	end
	return items
end


local function ForceSkillsAndTraitsToAll()

end

local function ForceSkillsAndTraitsToSurvivor(survivor)

end

-- ForEachPreset("CharacterDef", function(unit, group) print(unit.id) end)
-- CurrentModOptions.OnlyTameableFauna

local function ApplySkills()
end

local function ApplyTraits()
end
