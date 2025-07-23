--[[
	Saving this mod using the mod editor will break the dynamic generation of mod options.
	
	Fix by adding the line below to item.lua (it shoudld be the only thing in the file).

	To Edit/Add mod items: 
		1. Change files in Templates folder (can copy mod editor generated code to there)
		2. Run 'python3 templates_generator.py' to rebuild Templates.lua
			FSaT_BuildItems() will convert Templates.lua contents to equivalent mod items at runtime
]]
return FSaT_BuildItems()
