return {
PlaceObj('ModItemOptionNumber', {
	'name', "AllSkillsValue",
	'NameColor', RGBA(191, 183, 175, 255),
	'DisplayName', "`",
	'Help', "All skills value. Used by option above.",
	'DisplayColor', RGBA(20, 20, 20, 255),
	'DefaultValue', 3,
	'MaxValue', 10,
}),
PlaceObj('ModItemOptionChoice', {
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
		"Change Interested to Normal",
	},
}),
}
