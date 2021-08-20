local NativeFS = require("lib.nativefs")
local Serpent = require("lib.serpent.src.serpent")
local Slab = require("lib.Slab")

local Cell = require("source.cell")
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
local temp = {}

function Editor.new_level(t)
	local data = t.metadata or t
	Editor.current_level = Level(data)
	fnt_tile = love.graphics.newFont(data.tile_size)
	fnt_tile:setFilter("nearest", "nearest")
	Tiles.init()
	Editor.fill_tiles()
	temp.x = 0
	temp.y = 0
	temp.rows = Editor.current_level.rows
	temp.cols = Editor.current_level.cols
end

function Editor.open_level(path)
	Editor.path = path
	local filename = path:match("^.+/(.+)$")
	filename = filename:sub(0, -5)
	local data = NativeFS.load(path)()
	Editor.new_level(data)
	Editor.fill_objects(data)
	package.loaded[filename] = nil
end

function Editor.fill_tiles(cols, rows)
	local ww, wh = love.graphics.getDimensions()
	local tile_size = Editor.current_level.tile_size
	cols = cols or Editor.current_level.cols
	rows = rows or Editor.current_level.rows
	for y = 1, rows do
		for x = 1, cols do
			local cell = Cell(x, y, tile_size)
			insert(Editor.current_level.cells, cell)
		end
	end
end

function Editor.fill_objects(data)
	local cl = Editor.current_level
	for y = 1, cl.rows do
		for x = 1, cl.cols do
			local i = ((y - 1) * cl.cols) + x
			local t = data.tiles[i]
			local o = data.objects[i]
			local c, ac

			if t ~= 0 then
				c = cl.cells[i]
				ac = Tiles.get_tile_data(t)
			end

			if o then
				local index = ((o.y - 1) * cl.cols) + o.x
				c = cl.cells[index]
				ac = Tiles.get_obj_data(o.data.symbol)
			end

			if c and ac then
				c:set_tile(ac, fnt_tile, o and o.data)
			end
		end
	end
end

function Editor.resize()
	local cl = Editor.current_level
	if cl.rows == temp.rows and cl.cols == temp.cols then return end

	local t2d = cl:to_2d()
	local dx = temp.cols - cl.cols
	local dy = temp.rows - cl.rows
	t2d = cl:resize(t2d, dx, dy)
	local t1d = cl:to_1d(t2d)
	cl.cells = t1d

	cl.cols = temp.cols
	cl.rows = temp.rows
	temp.x = 0
	temp.y = 0
end

function Editor.interact_cell(mx, my, mb)
	if Dialog.is_open() then return end
	local cl = Editor.current_level
	local mx, my = love.mouse.getPosition()
	local tmx, tmy = Editor.translate_mouse(mx, my)
	for _, c in ipairs(cl.cells) do
		if c.hovered then
			local ac = Tiles.get_active_tile()
			if ac and mb == 1 then
				c:set_tile(ac, fnt_tile)
			elseif mb == 2 then
				c:remove_tile()
			end
			return
		end
	end
end

function Editor.save(is_readable)
	if not Editor.current_level then return end

	local base = NativeFS.getWorkingDirectory() .. "/levels/"
	if not NativeFS.getInfo(base) then
		NativeFS.createDirectory(base)
	end

	local opt
	if is_readable then
		opt = {compact = true, indent = "\t"}
	end
	local data = Editor.current_level:serialize()
	local filename = data.metadata.name .. ".lua"
	filename = base .. filename

	if love.filesystem.getInfo(filename) then
		local btn = love.window.showMessageBox("Warning",
			"File already exists. Overwrite it?",
			{"OK", "Cancel", escapebutton = 2},
			"warning")

		if btn == 2 then
			return
		end
	end

	local serialized = Serpent.dump(data, opt)
	local success, message = NativeFS.write(filename, serialized)
	Dialog.open_saved(filename, success, message, serialized)
end

function Editor.update(dt)
	if not Editor.current_level then return end

	if Slab.IsKeyDown("lctrl") and Slab.IsKeyDown("lshift") and
		Slab.IsKeyPressed("s") then
		Editor.save(true)
	elseif Slab.IsKeyDown("lctrl") and Slab.IsKeyPressed("s") then
		Editor.save(false)
	end

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
	local cl = Editor.current_level
	if not cl then return end
	Slab.BeginWindow("settings", {
		Title = "Settings",
	})
	if Slab.BeginTree("Level") then
		Slab.Indent()
		if Slab.Input("Name", {
			Text = cl.name,
		}) then
			cl.name = Slab.GetInputText()
		end
		Slab.SameLine()
		if Slab.Button("OK") then
			cl.orig_name = cl.name
		end

		Slab.Separator()
		Slab.BeginLayout("layout", {Columns = 2})
		Slab.SetLayoutColumn(1)
		Slab.Text("X:")
		Slab.Text("Y:")
		Slab.Text("Width:")
		Slab.Text("Height:")

		Slab.SetLayoutColumn(2)
		if Slab.InputNumberDrag("x", temp.x, 0, temp.cols, 1) then
			temp.x = Slab.GetInputNumber()
		end

		if Slab.InputNumberDrag("y", temp.y, 0, temp.rows, 1) then
			temp.y = Slab.GetInputNumber()
		end

		if Slab.InputNumberDrag("width", temp.cols, 1, 128, 1) then
			temp.cols = Slab.GetInputNumber()
		end

		if Slab.InputNumberDrag("height", temp.rows, 1, 128, 1) then
			temp.rows = Slab.GetInputNumber()
		end
		Slab.EndLayout()

		if Slab.Button("Apply") then
			Editor.resize()
		end

		Slab.Unindent()
		Slab.EndTree()
	end

	Slab.Separator()

	if Slab.BeginTree("Grid") then
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

function Editor.translate_mouse(mx, my)
	local ox, oy = Editor.get_gtid_translation()
	local tmx = (mx - ox) / zoom
	local tmy = (my - oy) / zoom
	return tmx, tmy
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

	if temp.x ~= 0 or temp.y ~= 0 or
		temp.cols ~= cl.cols or temp.rows ~= cl.rows then
		love.graphics.setColor(0, 0, 1, 1)
		love.graphics.rectangle("line",
			(temp.x + 1) * cl.tile_size,
			(temp.y + 1) * cl.tile_size,
			temp.cols * cl.tile_size,
			temp.rows * cl.tile_size)
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
	Editor.interact_cell(mx, my, mb)
end

function Editor.wheelmoved(wx, wy)
	if not Editor.current_level then return end
	if Slab.IsVoidHovered() then
		zoom = zoom + wy * zoom_factor
	end
end

return Editor
