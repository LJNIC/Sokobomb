local Slab = require("lib.Slab")

local About = require("source.about")
local Editor = require("source.editor")
local NewLevel = require("source.new_level")

local MenuBar = {}

function MenuBar.draw()
	local title = Editor.current_level and Editor.current_level.name or ""

	if Slab.BeginMainMenuBar() then
		if Slab.BeginMenu(title, {Enabled = false}) then
			Slab.EndMenu()
		end

		if Slab.BeginMenu("Menu") then
			if Slab.BeginMenu("New") then
				if Slab.MenuItem("Level") then
					Slab.OpenDialog("NewLevelDialog")
				end
				Slab.EndMenu()
			end

			if Slab.MenuItem("Save", {
				Enabled = Editor.current_level ~= nil,
			}) then
				Editor.save()
			end

			if Slab.MenuItem("Restart") then
				love.event.quit("restart")
			end

			if Slab.MenuItem("Exit") then
				love.event.quit()
			end
			Slab.EndMenu()
		end

		if Slab.BeginMenu("Shortcuts") then
			Slab.MenuItem("ctrl + n > New File")
			Slab.MenuItem("left click in grid > Place Tile")
			Slab.MenuItem("right click in grid > Open Context Menu")
			Slab.MenuItem("shift + left click in grid > Continuous Place Tile")
			Slab.MenuItem("ctrl + right click in grid > Remove Tile")
			Slab.EndMenu()
		end

		if Slab.BeginMenu("About") then
			if Slab.MenuItem("About") then
				Slab.OpenDialog("AboutDialog")
			end
			Slab.EndMenu()
		end

		Slab.EndMainMenuBar()
	end
end

return MenuBar
