return {
PlaceObj('ModItemOptionChoice', {
	'name', "ApplyWhen",
	'DisplayName', "Apply When",
	'Help', "When this mod should make changes to survivors.",
	'DefaultValue', "Survivor Joins & new game",
	'ChoiceList', {
		"Survivor Joins & new game",
		"On Game Load",
		"Never (disable mod)",
	},
}),
PlaceObj('ModItemOptionChoice', {
	'name', "ApplyTo",
	'DisplayName', "Apply To",
	'Help', "Which survivors to apply the changes to.",
	'DefaultValue', "*All Survivors*",
	'ChoiceList', "{$OptionApplyToChoiceList()}",
	})
}),
}
