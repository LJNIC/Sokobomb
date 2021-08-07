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
		kind = "player"
	},
	{
		symbol = "#",
		name = "Wall",
		color = {1, 0, 0},
		is_wall = true,
		kind = "tiles"
	},
	{
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
		kind = "tiles"
	},
	{
		symbol = "b",
		name = "Box",
		color = {0.57, 0.24, 0.11},
		is_box = true,
		kind = "boxes"
	},
	{
		symbol = "B",
		name = "Bomb",
		color = {0, 0, 0},
		timer = 5,
		is_bomb = true,
		kind = "bombs"
	},
}

function Tiles.init()
	active_tile_index = 0
end

function Tiles.draw()
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

function Tiles.get_active_tile()
	return tiles[active_tile_index]
end

function Tiles.get_mode()
	return mode
end

return Tiles
