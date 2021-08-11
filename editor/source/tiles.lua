local Slab = require("lib.Slab")

local Tiles = {}

local modes = {"Single", "Continuous"}
local mode = modes[1]
local active_tile_index = 0

local tiles = {
	-- {symbol = "-", name = "Floor", color = {0.5, 0.5, 0.5}},
	{
		symbol = "P",
		name = "Player",
		color = {0.11, 0.75, 0.69},
		is_player = true,
		kind = "objects"
	},
	{
		tile_n = 1,
		symbol = "#",
		name = "Wall",
		color = {1, 0, 0},
		is_wall = true,
		kind = "tiles"
	},
	{
		tile_n = 2,
		symbol = "G",
		name = "Goal",
		color = {0, 1, 0},
		is_goal = true,
		kind = "tiles"
	},
	{
		tile_n = 3,
		symbol = "X",
		name = "Border",
		color = {1, 0, 0},
		is_border = true,
		kind = "tiles"
	},
	{
		symbol = "~",
		name = "Destructible Wall",
		color = {0, 0, 1},
		is_d_wall = true,
		kind = "objects"
	},
	{
		symbol = "b",
		name = "Box",
		color = {0.57, 0.24, 0.11},
		is_box = true,
		kind = "objects"
	},
	{
		symbol = "B",
		name = "Bomb",
		color = {0, 0, 0},
		timer = 5,
		is_bomb = true,
		kind = "objects"
	},
}

function Tiles.init()
	active_tile_index = 0
end

function Tiles.draw()
	if Slab.IsKeyPressed("1") then
		active_tile_index = 1
	elseif Slab.IsKeyPressed("2") then
		active_tile_index = 2
	elseif Slab.IsKeyPressed("3") then
		active_tile_index = 3
	elseif Slab.IsKeyPressed("4") then
		active_tile_index = 4
	elseif Slab.IsKeyPressed("5") then
		active_tile_index = 5
	elseif Slab.IsKeyPressed("6") then
		active_tile_index = 6
	elseif Slab.IsKeyPressed("escape") then
		active_tile_index = 0
	end

	Slab.BeginWindow("tiles", {
		Title = "Tiles",
	})
	Slab.Text("Tiles List")
	Slab.BeginListBox("Tiles List", {
		StretchW = true,
	})
		for i = 1, #tiles do
			local t = tiles[i]
			Slab.BeginListBoxItem(t.name, {Selected = active_tile_index == i})
				Slab.Text(t.symbol ..  "  :  " .. t.name)
				if Slab.IsListBoxItemClicked() then
					active_tile_index = i
				end
			Slab.EndListBoxItem()
		end
	Slab.EndListBox()

	Slab.Text("Placement Mode")

	if Slab.BeginComboBox("cb_mode", {Selected = mode}) then
		for _, v in ipairs(modes) do
			if Slab.TextSelectable(v) then
				mode = v
			end
		end
		Slab.EndComboBox()
	end

	Slab.SameLine()

	if Slab.Button("Cancel", {
		Tooltip = "Cancel placing of tiles",
		Disabled = active_tile_index == 0,
	}) then
		active_tile_index = 0
	end

	if Slab.IsKeyPressed("lshift") then
		mode = "Continuous"
	elseif Slab.IsKeyReleased("lshift") then
		mode = "Single"
	end

	Slab.EndWindow()
end

function Tiles.get_tile_data(tile_n)
	for _, v in ipairs(tiles) do
		if v.tile_n and (v.tile_n == tile_n) then
			return v
		end
	end
end

function Tiles.get_obj_data(symbol)
	for _, v in ipairs(tiles) do
		if v.symbol == symbol then
			return v
		end
	end
end

function Tiles.get_active_tile()
	return tiles[active_tile_index]
end

function Tiles.get_mode()
	return mode
end

return Tiles
