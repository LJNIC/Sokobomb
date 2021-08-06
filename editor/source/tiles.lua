local Slab = require("lib.Slab")

local Tiles = {}

local active_tile_index = 0

local tiles = {
	{symbol = "P", name = "Player", color = {0.11, 0.75, 0.69}},
	{symbol = "-", name = "Floor", color = {0.5, 0.5, 0.5}},
	{symbol = "#", name = "Wall", color = {1, 0, 0}},
	{symbol = "G", name = "Goal", color = {0, 1, 0}},
	{symbol = "~", name = "Destructible Wall", color = {0, 0, 1}},
	{symbol = "b", name = "Box", color = {0.57, 0.24, 0.11}},
	{symbol = "B", name = "Bomb", color = {0, 0, 0}},
}

function Tiles.init()
	active_tile_index = 0
end

function Tiles.draw()
	Slab.BeginWindow("tiles", {
		Title = "Tiles",
	})
	Slab.Text("Tiles")
	Slab.BeginListBox("Tiles List", {
		StretchW = true,
	})
		for i = 1, #tiles do
			local t = tiles[i]
			Slab.BeginListBoxItem(t.name, {Selected = active_tile_index == i})
				Slab.Text(t.symbol ..  "  -  " .. t.name)
				if Slab.IsListBoxItemClicked() then
					active_tile_index = i
				end
			Slab.EndListBoxItem()
		end
	Slab.EndListBox()

	Slab.EndWindow()
end

function Tiles.get_active_tile()
	return tiles[active_tile_index]
end

return Tiles
