local Slab = require("lib.Slab")

local Editor = require("source.editor")
local LevelData = require("source.level_data")

local NewLevel = {}

function NewLevel.draw()
	if Slab.IsKeyDown("lctrl") and Slab.IsKeyPressed("n") then
		Slab.OpenDialog("NewLevelDialog")
	end

	if Slab.BeginDialog("NewLevelDialog", {
		Title = "New Level",
	}) then
		LevelData.draw_get_sizes()
		Slab.Separator()
		if Slab.Button("Create") or Slab.IsKeyPressed("return") then
			Editor.new_level(LevelData.get_data())
			Slab.CloseDialog()
		end
		Slab.SameLine()
		if Slab.Button("Cancel") then
			Slab.CloseDialog()
		end

		Slab.EndDialog()
	end
end

return NewLevel
