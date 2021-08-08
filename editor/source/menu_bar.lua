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

			if Slab.BeginMenu("Save", {
				Enabled = Editor.current_level ~= nil,
			}) then
				if Slab.MenuItem("Readable") then
					Editor.save(true)
				end
				if Slab.MenuItem("Compact") then
					Editor.save(false)
				end
				Slab.EndMenu()
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
			Slab.MenuItem("ctrl + n > New Level")
			Slab.MenuItem("ctrl + s > Save Level (compact)")
			Slab.MenuItem("ctrl + shift + s > Save Level (readable)")
			Slab.Separator()
			Slab.MenuItem("left click in grid > Place Tile")
			Slab.MenuItem("right click in grid > Open Context Menu")
			Slab.MenuItem("shift + left click in grid > Continuous Place Tile")
			Slab.MenuItem("ctrl + right click in grid > Remove Tile")
			Slab.Separator()
			Slab.MenuItem("1 to 6 > Switch Tiles for Placement")
			Slab.MenuItem("esc > Cancel tile placement mode")
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
