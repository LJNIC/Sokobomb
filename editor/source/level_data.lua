local Slab = require("lib.Slab")

local Helper = require("source.helper")

local LevelData = {}

local data = {
	name = "Untitled",
	tile_size = 32,
	rows = 16,
	cols = 16,
}

function LevelData.draw_get_sizes()
	Slab.BeginLayout("layout", {Columns = 2})
		Slab.SetLayoutColumn(1)
		Slab.Text("Level name")
		Slab.Text("Tile Size")
		Slab.Text("Rows")
		Slab.Text("Columns")

		Slab.SetLayoutColumn(2)
		if Slab.Input("in_level_name", {
			Text = data.name,
			ReturnOnText = true,
		}) then
			data.name = Slab.GetInputText()
		end
		data.tile_size = Helper.get_input_int("in_tile_size", data.tile_size)
		data.rows = Helper.get_input_int("in_rows", data.rows)
		data.cols = Helper.get_input_int("in_cols", data.cols)
	Slab.EndLayout()
end

function LevelData.get_data()
	return data
end

return LevelData
