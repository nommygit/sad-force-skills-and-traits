-- These functions exist here to solve a load order issue with Templates.lua and ModItems.lua referencing bits of eachoter.

-- Returns a table array containing the full names of all defined survivors (CharacterDefs)
function FSaT_SurvivorNamesArray()
	local names = {}
	ForEachPreset("CharacterDef", function(unit, group) 
		table.insert(names, _InternalTranslate(unit.FirstName).." ".._InternalTranslate(unit.LastName))
	end)
	return names
end

-- Returns a table which is tbl with survivor names added to the end
function FSaT_AppendSurvivorNamesArray(tbl)
	local survivorNames = FSaT_SurvivorNamesArray() or {}
	for _, name in ipairs(survivorNames) do
		table.insert(tbl, name)
	end
	return tbl
end