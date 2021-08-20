local Slab = require("lib.Slab")

local concat = table.concat

local Dialog = {
	opened_s = false,
	opened_bt = false,
}

local active_cell
local messages = {}
local serialized

function Dialog.is_open()
	return Dialog.opened_s or Dialog.opened_bt
end

function Dialog.open_saved(filename, success, msg, ser)
	if success then
		messages[1] = "File saved to: " .. filename
		serialized = ser
	else
		messages[1] = "Error: " .. msg
	end
	Slab.OpenDialog("saved_dialog")
end

function Dialog.open_bomb_timer(cell)
	active_cell = cell
	Slab.OpenDialog("bomb_timer_dialog")
end

function Dialog.draw()
	Dialog.opened_s = Slab.BeginDialog("saved_dialog", {
		Title = "File Saved",
	})
	if Dialog.opened_s then
		Slab.BeginLayout("saved_layout", {AlignX = "center"})
			for _, str in ipairs(messages) do
				Slab.Text(str)
			end
		Slab.EndLayout()
		Slab.Separator()
		if Slab.Button("OK") then
			Slab.CloseDialog()
		end
		Slab.SameLine()
		if Slab.Button("Copy To Clipboard") then
			love.system.setClipboardText(serialized)
			messages[2] = "Copied to clipboard"
		end
		Slab.EndDialog()
	end

	Dialog.opened_bt = Slab.BeginDialog("bomb_timer_dialog", {
		Title = "Bomb Timer",
	})
	if Dialog.opened_bt then
		Slab.BeginLayout("layout", {Columns = 2})
			Slab.SetLayoutColumn(1)
			Slab.Text("Timer: ")
			Slab.SetLayoutColumn(2)
			if Slab.InputNumberSlider("bomb_timer", active_cell.tile.timer, 0, 99, {
				Precision = 0,
			}) then
				active_cell.tile.timer = Slab.GetInputNumber()
			end
			Slab.SetInputFocus("bomb_timer")
			Slab.SetInputCursorPos(#tostring(active_cell.tile.timer))
		Slab.EndLayout()

		Slab.Separator()

		if Slab.Button("Confirm") or Slab.IsKeyPressed("return") then
			Slab.CloseDialog()
		end

		Slab.EndDialog()
	end
end

return Dialog
