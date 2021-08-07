local Slab = require("lib.Slab")

local Dialog = require("source.dialog")

local ContextMenu = {
	is_open = false
}

local clicked_cell

function ContextMenu.open(cell)
	clicked_cell = cell
	ContextMenu.is_open = true
end

function ContextMenu.draw()
	ContextMenu.is_open = clicked_cell ~= nil
	if not ContextMenu.is_open then return end
	if Slab.BeginContextMenuWindow() then
		if Slab.MenuItem("Edit Tile", {
			Enabled = (clicked_cell.tile and clicked_cell.tile.is_bomb) ~= nil,
		}) then
			Dialog.open_bomb_timer(clicked_cell)
		end

		if Slab.MenuItem("Remove Tile", {
			Enabled = clicked_cell.tile ~= nil,
		}) then
			clicked_cell:remove_tile()
		end

		Slab.EndContextMenu()
	else
		clicked_cell = nil
	end
end

return ContextMenu
