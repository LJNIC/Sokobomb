local Serpent = require("lib.serpent.src.serpent")
local Slab = require("lib.Slab")

local Cell = require("source.cell")
local ContextMenu = require("source.context_menu")
local Dialog = require("source.dialog")
local Helper = require("source.helper")
local Level = require("source.level")
local Tiles = require("source.tiles")

local insert = table.insert

local Editor = {
	current_level = nil,
}

local col_to_edit
local col_lines = {1, 0, 0, 1}
local col_cell = {1, 1, 1, 1}
local col_hovered = {1, 1, 0, 1}
local zoom = 1
local zoom_factor = 0.15
local fnt_tile

function Editor.new_level(data)
	Editor.current_level = Level(data)
	fnt_tile = love.graphics.newFont(data.tile_size)
	fnt_tile:setFilter("nearest", "nearest")
	Tiles.init()

	local ww, wh = love.graphics.getDimensions()
	local tile_size = Editor.current_level.tile_size
	local rows = Editor.current_level.rows
	local cols = Editor.current_level.cols
	for y = 0, rows - 1 do
		for x = 0, cols - 1 do
			local cell = Cell(x, y, tile_size)
			insert(Editor.current_level.cells, cell)
		end
	end
end

function Editor.interact_cell(mx, my, mb)
	if ContextMenu.is_open then return end
	if Dialog.is_open() then return end
	local cl = Editor.current_level
	local mx, my = love.mouse.getPosition()
	local tmx, tmy = Editor.translate_mouse(mx, my)
	for _, c in ipairs(cl.cells) do
		if c.hovered then
			local ac = Tiles.get_active_tile()
			if ac and mb == 1 then
				c:set_tile(ac, fnt_tile)
			elseif love.keyboard.isDown("lctrl") and mb == 2 then
				c:remove_tile()
			elseif c.tile and mb == 2 then
				ContextMenu.open(c)
			end
			return
		end
	end
end

function Editor.save()
	if not Editor.current_level then return end
	local data = Editor.current_level:serialize()
	local filename = data.metadata.name .. ".lua"
	local serialized = Serpent.dump(data, {compact = false, indent = "\t"})
	local success, message = love.filesystem.write(filename, serialized)
	Dialog.open_saved(filename, success, message, serialized)
end

function Editor.update(dt)
	if not Editor.current_level then return end

	if Slab.IsKeyDown("lctrl") and Slab.IsKeyPressed("s") then
		Editor.save()
	end

	if not (Tiles.get_mode() == "Continuous") then return end
	local mb
	if love.mouse.isDown(1) then
		mb = 1
	elseif love.mouse.isDown(2) then
		mb = 2
	end
	if mb then
		local mx, my = love.mouse.getPosition()
		Editor.interact_cell(mx, my, mb)
	end
end

function Editor.draw()
	if not Editor.current_level then return end
	Slab.BeginWindow("settings", {
		Title = "Settings",
	})
	if Slab.BeginTree("Grid Settings") then
		Slab.Indent()

		Slab.Text("Cell color")
		Slab.SameLine()
		if Slab.Button("edit") then
			col_to_edit = col_cell
		end

		Slab.Text("Cell Line color")
		Slab.SameLine()
		if Slab.Button("edit") then
			col_to_edit = col_lines
		end

		Slab.Text("Hovered cell color")
		Slab.SameLine()
		if Slab.Button("edit") then
			col_to_edit = col_hovered
		end

		Slab.Unindent()
		Slab.EndTree()
	end

	Slab.Separator()

	if Slab.BeginTree("Mouse") then
		Slab.Indent()
		if Slab.BeginTree("Screen") then
			Slab.Indent()
			local mx, my = love.mouse.getPosition()
			Slab.Text("x: ")
			Slab.SameLine()
			Slab.Text(tostring(mx))

			Slab.Text("y: ")
			Slab.SameLine()
			Slab.Text(tostring(my))

			Slab.Unindent()
			Slab.EndTree()
		end

		if Slab.BeginTree("Grid") then
			Slab.Indent()
			local mx, my = love.mouse.getPosition()
			local tmx, tmy = Editor.translate_mouse(mx, my)
			Slab.Text("x: ")
			Slab.SameLine()
			Slab.Text(tostring(tmx))

			Slab.Text("y: ")
			Slab.SameLine()
			Slab.Text(tostring(tmy))

			Slab.Unindent()
			Slab.EndTree()
		end

		Slab.Unindent()
		Slab.EndTree()
	end

	Slab.Text("Zoom")
	Slab.SameLine()
	if Slab.InputNumberSlider("zoom", zoom, 0.25, 4, {
		Precision = 2,
	}) then
		zoom = Slab.GetInputNumber()
	end

	Slab.EndWindow()

	Tiles.draw()

	local res = Helper.draw_color_picker(col_to_edit)
	if res == -1 then
		col_to_edit = nil
	end
end

function Editor.translate_mouse(mx, my)
	local ox, oy = Editor.get_gtid_translation()
	local tmx = mx - ox * zoom
	local tmy = my - oy * zoom
	return tmx, tmy
end

function Editor.get_gtid_translation()
	local ww, wh = love.graphics.getDimensions()
	local cl = Editor.current_level
	local tile_size = cl.tile_size
	local rows = cl.rows
	local cols = cl.cols
	local ox = (ww * 0.5) - (cols * tile_size * 0.5 * zoom)
	local oy = (wh * 0.5) - (rows * tile_size * 0.5 * zoom)
	return ox, oy
end

function Editor.draw_grid()
	if not Editor.current_level then return end
	local cl = Editor.current_level
	local ox, oy = Editor.get_gtid_translation()
	local mx, my = love.mouse.getPosition()
	local tmx, tmy = Editor.translate_mouse(mx, my)

	love.graphics.push()
	love.graphics.translate(ox, oy)
	love.graphics.scale(zoom)

	for _, c in ipairs(cl.cells) do
		if c:is_hovered(tmx, tmy) then
			love.graphics.setColor(col_hovered)
		else
			love.graphics.setColor(col_cell)
		end
		c:draw(false) --fill

		love.graphics.setColor(col_lines)
		c:draw(true) --line
	end

	love.graphics.pop()

	local tile = Tiles.get_active_tile()
	if tile then
		local prev_fnt = love.graphics.getFont()
		love.graphics.setFont(fnt_tile)
		love.graphics.setColor(tile.color)
		love.graphics.print(tile.symbol,
			mx - cl.tile_size * 0.5,
			my - cl.tile_size * 0.5
		)
		love.graphics.setFont(prev_fnt)
	end
end

function Editor.mousepressed(mx, my, mb)
	if not Editor.current_level then return end
	if not (Tiles.get_mode() == "Single") then return end
	Editor.interact_cell(mx, my, mb)
end

function Editor.wheelmoved(wx, wy)
	if not Editor.current_level then return end
	if Slab.IsVoidHovered() then
		zoom = zoom + wy * zoom_factor
	end
end

return Editor
