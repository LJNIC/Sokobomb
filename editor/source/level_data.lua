local Slab = require("lib.Slab")

local Helper = require("source.helper")

local LevelData = {}

local data = {
	filename = "Untitled",
	name = "",
	tile_size = 32,
	rows = 16,
	cols = 16,
	zoom = 2,
}

function LevelData.draw_get_sizes()
	Slab.BeginLayout("layout", {Columns = 2})
		Slab.SetLayoutColumn(1)
		Slab.Text("Level Filename")
		Slab.Text("Level Name")
		Slab.Text("Tile Size")
		Slab.Text("Height")
		Slab.Text("Width")
		Slab.Text("Zoom")

		Slab.SetLayoutColumn(2)
		if Slab.Input("in_level_filename", {
			Text = data.filename,
			ReturnOnText = true,
		}) then
			data.filename = Slab.GetInputText()
		end
		if Slab.Input("in_level_name", {
			Text = data.name,
			ReturnOnText = true,
		}) then
			data.name = Slab.GetInputText()
		end
		data.tile_size = Helper.get_input_int("in_tile_size", data.tile_size)
		data.rows = Helper.get_input_int("in_rows", data.rows)
		data.cols = Helper.get_input_int("in_cols", data.cols)
		data.zoom = Helper.get_input_float("in_zoom", data.zoom)
	Slab.EndLayout()
end

function LevelData.get_data()
	return data
end

return LevelData
