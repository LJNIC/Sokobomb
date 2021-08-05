local Slab = require("lib.Slab")

local Helper = require("source.helper")
local Level = require("source.level")

local Editor = {
	current_level = nil
}

local col_to_edit
local col_lines = {1, 0, 0, 1}
local col_cell = {1, 1, 1, 1}
local zoom = 1
local zoom_factor = 0.15

function Editor.new_level(data)
	Editor.current_level = Level(data)
end

function Editor.draw()
	if not Editor.current_level then return end
	Slab.BeginWindow("settings", {
		Title = "Settings",
	})
	if Slab.BeginTree("Grid Settings") then
		Slab.Indent()

		Slab.Text("Grid line color")
		Slab.SameLine()
		if Slab.Button("edit") then
			col_to_edit = col_lines
		end

		Slab.Text("Grid cell color")
		Slab.SameLine()
		if Slab.Button("edit") then
			col_to_edit = col_cell
		end

		Slab.Unindent()
		Slab.EndTree()
	end

	Slab.Separator()
	Slab.Text("Zoom")
	Slab.SameLine()
	if Slab.InputNumberSlider("zoom", zoom, 0.25, 4, {
		Precision = 2,
	}) then
		zoom = Slab.GetInputNumber()
	end
	Slab.EndWindow()

	local res = Helper.draw_color_picker(col_to_edit)
	if res == -1 then
		col_to_edit = nil
	end
end

function Editor.draw_grid()
	if not Editor.current_level then return end
	local ww, wh = love.graphics.getDimensions()
	local tile_size = Editor.current_level.tile_size
	local rows = Editor.current_level.rows
	local cols = Editor.current_level.cols

	love.graphics.push()
	love.graphics.translate(
		(ww * 0.5) - (cols * tile_size * 0.5 * zoom),
		(wh * 0.5) - (rows * tile_size * 0.5 * zoom)
	)
	love.graphics.scale(zoom)

	for y = 0, rows - 1 do
		for x = 0, cols - 1 do
			love.graphics.setColor(col_cell)
			love.graphics.rectangle("fill",
				x * tile_size,
				y * tile_size,
				tile_size, tile_size
			)

			love.graphics.setColor(col_lines)
			love.graphics.rectangle("line",
				x * tile_size,
				y * tile_size,
				tile_size, tile_size
			)
		end
	end

	love.graphics.pop()
end

function Editor.wheelmoved(wx, wy)
	zoom = zoom + wy * zoom_factor
end

return Editor
