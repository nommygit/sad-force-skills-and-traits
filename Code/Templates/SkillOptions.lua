return {
PlaceObj('ModItemOptionChoice', {
	'name', "{$id}Action",
	'DisplayName', "{$DisplayName}",
	'Help', "{$Description}",
	'DefaultValue', "Don't change",
	'ChoiceList', {
		"Don't change",
		"Set to:",
		"Set to Minimum of:",
		"Set to Maximum of:",
	},
}),
PlaceObj('ModItemOptionNumber', {
	'name', "{$id}Value",
	'NameColor', RGBA(191, 183, 175, 255),
	'DisplayName', "{$DisplayName}",
	'Help', "{$DisplayName} value. Used by option above.",
	'DisplayColor', RGBA(20, 20, 20, 255),
	'DefaultValue', 3,
	'MaxValue', 10,
}),
PlaceObj('ModItemOptionChoice', {
	'name', "{$id}Inclination",
	'DisplayName', "{$DisplayName} Inclination",
	'Help', "{$Description}",
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