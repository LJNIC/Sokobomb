require("lib.batteries"):export()
local Slab = require("lib.Slab")
local Style = Slab.GetStyle()

local About = require("source.about")
local Dialog = require("source.dialog")
local Editor = require("source.editor")
local Files = require("source.files")
local MenuBar = require("source.menu_bar")
local NewLevel = require("source.new_level")

function love.load()
	Style.API.LoadStyle("slab.style")
	Slab.Initialize()
	Style.API.SetStyle("slab")
end

function love.update(dt)
	Slab.Update(dt)

	MenuBar.draw()
	About.draw()
	NewLevel.draw()
	Editor.update(dt)
	Editor.draw()
	Dialog.draw()
	Files.draw()
end

function love.draw()
	Editor.draw_grid()
	Slab.Draw()
end

function love.keypressed(key)
	Editor.keypressed(key)
end

function love.mousepressed(mx, my, mb)
	Editor.mousepressed(mx, my, mb)
end

function love.wheelmoved(wx, wy)
	Editor.wheelmoved(wx, wy)
end
