local Slab = require("lib.Slab")

local Tiles = {}

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
		color = {48/255, 54/255, 95/255},
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
		symbol = "~",
		name = "Destructible Wall",
		color = {0, 0, 1},
		is_d_wall = true,
		kind = "objects"
	},
	{
		symbol = "b",
		name = "Box",
		color = {92/255, 204/255, 150/255},
		is_box = true,
		kind = "objects"
	},
	{
		symbol = "B",
		name = "Bomb",
		color = {227/255, 52/255, 0},
		timer = "",
		is_bomb = true,
		kind = "objects"
	},
	{
		symbol = "∞",
		name = "Infinite",
		color = {0, 0, 0},
		is_infinite = true,
		kind = "objects"
	},

	--special tiles
	{
		symbol = "f",
		name = "Freeze",
		color = {2/255, 239/255, 192/255, 1},
		is_freeze = true,
		kind = "freeze",
		is_special = true,
	},
}

function Tiles.init()
	active_tile_index = 0
end

function Tiles.draw()
	if not Slab.IsAnyInputFocused() then
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
	end

	Slab.BeginWindow("tiles", {
		Title = "Tiles",
	})
	Slab.Text("Tiles List")
	Slab.BeginListBox("Tiles List", {
		StretchW = true,
		H = 360,
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

	if Slab.Button("Cancel", {
		Tooltip = "Cancel placing of tiles",
		Disabled = active_tile_index == 0,
	}) then
		active_tile_index = 0
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

function Tiles.get_bottom_tile_data(t)
	for _, v in ipairs(tiles) do
		if t.kind == v.kind then
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

return Tiles
