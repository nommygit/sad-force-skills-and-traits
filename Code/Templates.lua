--[[
AUTO-GENERATED CODE  DON'T EDIT DIRECTLY

This code was created by templates_generator.py based upon template files in the Templates folder.
]]
FSaT_Templates = {

	-- AllSkillsOptions.lua

	['AllSkillsOptions'] = {
		{ class = 'ModItemOptionChoice', args = {
				'name', "AllSkillsAction",
				'DisplayName', "*All Skills*",
				'Help', "Change the value for every skill.   Will be overriden by individual skill options set below e.g Combat",
				'DefaultValue', "Don't change",
				'ChoiceList', {
					"Don't change",
					"Set to:",
					"Set to Minimum of:",
					"Set to Maximum of:"}
		} },
		{ class = 'ModItemOptionNumber', args = {
				'name', "AllSkillsValue",
				'NameColor', RGBA(191, 183, 175, 255),
				'DisplayName', "`",
				'Help', "All skills value. Used by option above.",
				'DisplayColor', RGBA(20, 20, 20, 255),
				'DefaultValue', 3,
				'MaxValue', 10
		} },
		{ class = 'ModItemOptionChoice', args = {
				'name', "AllSkillsInclination",
				'DisplayName', "*All Skills* Inclination",
				'Help', "Change the inclination for every skill.   Will be overriden by any inclination options set below e.g Combat Inclination.",
				'DefaultValue', "Don't change",
				'ChoiceList', {
					"Don't change",
					"Set to Interested",
					"Set to Normal",
					"Set to Indifferent",
					"Change Indifferent to Normal",
					"Change Interested to Normal"}
		} }
	},

	-- AllTraitsOptions.lua

	['AllTraitsOptions'] = {
		{ class = 'ModItemOptionChoice', args = {
				'name', "AllTraitsAction",
				'DisplayName', "*All Traits*",
				'Help', "Add or remove all traits on survivors.   Will be overridden by any individual trait options set below e.g Hardworking.",
				'DefaultValue', "Don't change",
				'ChoiceList', {
					"Don't change",
					"Remove"}
		} }
	},

	-- ApplyOptions.lua

	['ApplyOptions'] = {
		{ class = 'ModItemOptionChoice', args = {
				'name', "ApplyWhen",
				'DisplayName', "Apply When",
				'Help', "When this mod should make changes to survivors.",
				'DefaultValue', "Survivor Joins & new game",
				'ChoiceList', {
					"Survivor Joins & new game",
					"On Game Load",
					"Never (disable mod)"}
		} },
		{ class = 'ModItemOptionChoice', args = {
				'name', "ApplyTo",
				'DisplayName', "Apply To",
				'Help', "Which survivors to apply the changes to.",
				'DefaultValue', "All Survivors",
				'ChoiceList', {
					"All Survivors",
					"Nobody (disable mod)",
					"Dick",
					"Jane",
					"Harry"}
		} }
	},

	-- DisplayFormattingGapOption.lua

	['DisplayFormattingGapOption'] = {
		{ class = 'ModItemOptionChoice', args = {
				'name', "_DisplayFormatting_Gap{$id}",
				'comment', "Display formatting only",
				'DisplayName', "`",
				'Help', "Display formatting only",
				'DisplayColor', RGBA(20, 20, 20, 255)
		} }
	},

	-- ModCodeItems.lua

	['ModCodeItems'] = {
		{ class = 'ModItemCode', args = {
				'CodeFileName', "Code/Templates.lua"
		} },
		{ class = 'ModItemCode', args = {
				'CodeFileName', "Code/ModItems.lua"
		} },
		{ class = 'ModItemCode', args = {
				'CodeFileName', "Code/SurvivorModification.lua"
		} }
	},

	-- SkillOptions.lua

	['SkillOptions'] = {
		{ class = 'ModItemOptionChoice', args = {
				'name', "${id}Action",
				'DisplayName', "${DisplayName}",
				'Help', "${Description}",
				'DefaultValue', "Don't change",
				'ChoiceList', {
					"Don't change",
					"Set to:",
					"Set to Minimum of:",
					"Set to Maximum of:"}
		} },
		{ class = 'ModItemOptionNumber', args = {
				'name', "${id}Value",
				'NameColor', RGBA(191, 183, 175, 255),
				'DisplayName', "${DisplayName}",
				'Help', "${DisplayName} value. Used by option above.",
				'DisplayColor', RGBA(20, 20, 20, 255),
				'DefaultValue', 3,
				'MaxValue', 10
		} },
		{ class = 'ModItemOptionChoice', args = {
				'name', "${id}Inclination",
				'DisplayName', "${DisplayName} Inclination",
				'Help', "${Description}",
				'DefaultValue', "Don't change",
				'ChoiceList', {
					"Don't change",
					"Set to Interested",
					"Set to Normal",
					"Set to Indifferent",
					"Change Indifferent to Normal",
					"Change Interested to Normal"}
		} }
	},

	-- TraitOptions.lua

	['TraitOptions'] = {
		{ class = 'ModItemOptionChoice', args = {
				'name', "${id}",
				'DisplayName', "${DisplayName}",
				'Help', "${Description}",
				'DefaultValue', "Don't change",
				'ChoiceList', {
					"Don't change",
					"Add",
					"Remove"}
		} }
	},

}