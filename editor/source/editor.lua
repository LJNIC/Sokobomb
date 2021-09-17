local NativeFS = require("lib.nativefs")
local Serpent = require("lib.serpent.src.serpent")
local Slab = require("lib.Slab")

local Cell = require("source.cell")
local Dialog = require("source.dialog")
local Helper = require("source.helper")
local Level = require("source.level")
local Tiles = require("source.tiles")

local max = math.max
local insert = table.insert
local floor = math.floor

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
local rect_select = {
	enabled = false,
	flag = false,
	start_pos = vec2(),
	end_pos = vec2(),
}

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
	rect_select.enabled = false
	rect_select.flag = false
	rect_select.start_pos = vec2()
	rect_select.end_pos = vec2()
end

function Editor.open_level(path)
	print("opening: " .. path)
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

			if t ~= 0 then
				local c = cl.cells[i]
				local ac = Tiles.get_tile_data(t)
				c:set_tile(ac, fnt_tile)
			end

			if o then
				local index = ((o.y - 1) * cl.cols) + o.x
				local c = cl.cells[index]
				local ac = Tiles.get_obj_data(o.data.symbol)
				c:set_tile(ac, fnt_tile, o and o.data)
			end
		end
	end
end

function Editor.resize()
	local cl = Editor.current_level
	if cl.rows == temp.rows and cl.cols == temp.cols then return end
	if (temp.x ~= 0) and temp.x + temp.cols > cl.cols then return end
	if (temp.y ~= 0) and temp.y + temp.rows > cl.rows then return end

	local t2d = cl:to_2d()
	t2d = cl:resize(t2d, temp.x, temp.y, temp.cols, temp.rows)
	cl.cells = cl:to_1d(t2d)
	cl.cols = temp.cols
	cl.rows = temp.rows
	temp.x = 0
	temp.y = 0
end

function Editor.fill_selected()
	local cl = Editor.current_level
	if not cl then return end
	if not rect_select.enabled then return end
	local ac = Tiles.get_active_tile()
	if not ac then return end

	local t2d = cl:to_2d()
	for y = temp.y + 1, temp.y + temp.rows do
		for x = temp.x + 1, temp.x + temp.cols do
			local c = t2d[y][x]
            c:set_tile(ac, fnt_tile)
		end
	end
	cl.cells = cl:to_1d(t2d)
end

function Editor.delete_selected()
	local cl = Editor.current_level
	if not cl then return end
	if not rect_select.enabled then return end

	local t2d = cl:to_2d()
	for y = temp.y + 1, temp.y + temp.rows do
		for x = temp.x + 1, temp.x + temp.cols do
			local c = t2d[y][x]
			c:remove_tile()
		end
	end
	cl.cells = cl:to_1d(t2d)
end

function Editor.interact_cell(mx, my, mb)
	if Dialog.is_open() then return end
	local cl = Editor.current_level
	local mx, my = love.mouse.getPosition()
	local tmx, tmy = Editor.translate_mouse(mx, my)
	for _, c in ipairs(cl.cells) do
		if c.hovered then
			local ac = Tiles.get_active_tile()
			if not rect_select.enabled and ac and mb == 1 then
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
	local filename = data.metadata.filename .. ".lua"
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

	Editor.do_rect_select()

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

function Editor.do_rect_select()
	if not rect_select.enabled then return end
	local cl = Editor.current_level
	local mx, my = love.mouse.getPosition()
	local tmx, tmy = Editor.translate_mouse(mx, my)
	local w, h = cl.cols * cl.tile_size, cl.rows * cl.tile_size

	if love.mouse.isDown(1) then
		if not rect_select.flag then
			if tmx >= 0 and tmx <= w and
				tmy >= 0 and tmy <= h then
				rect_select.flag = true
				rect_select.start_pos.x = tmx
				rect_select.start_pos.y = tmy
				local x = max(floor(rect_select.start_pos.x/cl.tile_size), 0)
				local y = max(floor(rect_select.start_pos.y/cl.tile_size), 0)
				temp.x = x - 1
				temp.y = y - 1
			end
		else
			rect_select.end_pos.x = tmx
			rect_select.end_pos.y = tmy
			local w = rect_select.end_pos.x - rect_select.start_pos.x
			local h = rect_select.end_pos.y - rect_select.start_pos.y
			temp.cols = max(floor(w/cl.tile_size), 1) + 1
			temp.rows = max(floor(h/cl.tile_size), 1) + 1
		end
	end
end

function Editor.draw()
	local cl = Editor.current_level
	if not cl then return end
	Slab.BeginWindow("settings", {
		Title = "Settings",
	})
	if Slab.CheckBox(rect_select.enabled, "Rectangular Selection") then
		rect_select.enabled = not rect_select.enabled
	end
	Slab.Separator()

	if Slab.BeginTree("Level") then
		Slab.Indent()

		Slab.Text("Filename:")
		if Slab.Input("Filename", {
			Text = cl.filename,
		}) then
			cl.filename = Slab.GetInputText()
		end

		Slab.Text("Name:")
		if Slab.Input("Name", {
			Text = cl.name,
		}) then
			cl.name = Slab.GetInputText()
		end

		Slab.SameLine()
		if Slab.Button("OK") then
			cl.orig_filename = cl.filename
			cl.orig_name = cl.name
		end

		Slab.Separator()
		Slab.Text("Selection")
		Slab.BeginLayout("layout", {Columns = 2})
		Slab.SetLayoutColumn(1)
		Slab.Text("X:")
		Slab.Text("Y:")
		Slab.Text("Width:")
		Slab.Text("Height:")

		Slab.SetLayoutColumn(2)
		Slab.Text(tostring(temp.x))
		Slab.Text(tostring(temp.y))

		--for some reason these mess with the rectangular selection
		-- if Slab.InputNumberDrag("x", temp.x, 0, temp.cols - 1, 1) then
			-- temp.x = Slab.GetInputNumber()
		-- end

		-- if Slab.InputNumberDrag("y", temp.y, 0, temp.rows - 1, 1) then
			-- temp.y = Slab.GetInputNumber()
		-- end

		if Slab.InputNumberDrag("width", temp.cols, 1, 128, 1) then
			temp.cols = Slab.GetInputNumber()
		end

		if Slab.InputNumberDrag("height", temp.rows, 1, 128, 1) then
			temp.rows = Slab.GetInputNumber()
		end
		Slab.EndLayout()

		if Slab.Button("Resize") then
			Editor.resize()
		end
		Slab.SameLine()
		if Slab.Button("Fill") then
			Editor.fill_selected()
		end
		Slab.SameLine()
		if Slab.Button("Delete") then
			Editor.delete_selected()
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

function Editor.get_grid_translation()
	local ww, wh = love.graphics.getDimensions()
	local cl = Editor.current_level
	local tile_size = cl.tile_size
	local cols = cl.cols
	local rows = cl.rows
	local ox = (ww * 0.5) - (cols * tile_size * 0.5 * zoom)
	local oy = (wh * 0.5) - (rows * tile_size * 0.5 * zoom)
	return ox, oy
end

function Editor.translate_mouse(mx, my)
	local ox, oy = Editor.get_grid_translation()
	local tmx = (mx - ox) / zoom
	local tmy = (my - oy) / zoom
	return tmx, tmy
end

function Editor.draw_grid()
	if not Editor.current_level then return end
	local cl = Editor.current_level
	local ox, oy = Editor.get_grid_translation()
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

	if rect_select.enabled and (temp.x ~= 0 or temp.y ~= 0 or
		temp.cols ~= cl.cols or temp.rows ~= cl.rows) then
		love.graphics.setColor(0, 0, 1, 1)
        love.graphics.setLineWidth(3)
		love.graphics.rectangle("line",
			(temp.x + 1) * cl.tile_size,
			(temp.y + 1) * cl.tile_size,
			temp.cols * cl.tile_size,
			temp.rows * cl.tile_size)
        love.graphics.setLineWidth(1)
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

function Editor.keypressed(key)
	if not Editor.current_level then return end
	if key == "r" then
		rect_select.enabled = not rect_select.enabled
	elseif key == "delete" or key == "backspace" then
		Editor.delete_selected()
	elseif key == "f" then
		Editor.fill_selected()
	end
end

function Editor.mousepressed(mx, my, mb)
	local cl = Editor.current_level
	if not cl then return end
	Editor.interact_cell(mx, my, mb)
	if rect_select.enabled and rect_select.flag then
		if mb == 1 then
			rect_select.flag = false
		end
	end
end

function Editor.wheelmoved(wx, wy)
	if not Editor.current_level then return end
	if Slab.IsVoidHovered() then
		zoom = zoom + wy * zoom_factor
	end
end

return Editor
