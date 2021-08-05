local Slab = require("lib.Slab")

local floor = math.floor

local Helper = {}

function Helper.draw_color_picker(col)
	if not col then return end
	local res = Slab.ColorPicker({Color = col})
	if res.Button == 1 then
		col[1] = res.Color[1]
		col[2] = res.Color[2]
		col[3] = res.Color[3]
	end
	return res.Button
end

function Helper.get_input_int(id, val)
	if Slab.Input(id, {
		Text = tostring(val),
		ReturnOnText = false,
		NumbersOnly = true,
		MinNumber = 1,
		MaxNumber = 128,
		Precision = 0,
	}) then
		return floor(Slab.GetInputNumber())
	end

	return val
end

return Helper
