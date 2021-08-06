local Slab = require("lib.Slab")

local Dialog = {
	is_open = false,
}

local active_cell

function Dialog.open_bomb_timer(cell)
	active_cell = cell
	Slab.OpenDialog("bomb_timer_dialog")
end

function Dialog.draw()
	Dialog.is_open = active_cell ~= nil

	if Slab.BeginDialog("bomb_timer_dialog", {
		Title = "Bomb Timer",
	}) then
		Slab.BeginLayout("layout", {Columns = 2})
			Slab.SetLayoutColumn(1)
			Slab.Text("Timer: ")
			Slab.SetLayoutColumn(2)
			if Slab.InputNumberSlider("bomb_timer", active_cell.tile.timer, 0, 99, {
				Precision = 0,
			}) then
				active_cell.tile.timer = Slab.GetInputNumber()
			end
		Slab.EndLayout()

		Slab.Separator()

		if Slab.Button("Confirm") then
			Slab.CloseDialog()
		end

		Slab.EndDialog()
	else
		active_cell = nil
	end
end

return Dialog
