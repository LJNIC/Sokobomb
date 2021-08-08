local Slab = require("lib.Slab")

local Editor = require("source.editor")
local LevelData = require("source.level_data")

local NewLevel = {}

local is_open_fd = false

function NewLevel.open_fd()
	is_open_fd = true
end

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

	if is_open_fd then
		local res = Slab.FileDialog({
			Directory = love.filesystem.getWorkingDirectory() .. "/levels",
			Type = "openfile"
		})
		if res.Button ~= "" then
			is_open_fd = false
			if res.Files[1] then
				Editor.open_level(res.Files[1])
			end
		end
	end
end

return NewLevel
