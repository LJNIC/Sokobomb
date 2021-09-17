local NativeFS = require("lib.nativefs")
local Slab = require("lib.Slab")

local Editor = require("source.editor")

local Files = {}

local list = {}
local items = {}
local path = NativeFS.getWorkingDirectory() .. "/levels/"

function Files.get_items()
	list = NativeFS.getDirectoryItems(path)
	for _, f in ipairs(list) do
		local d = NativeFS.load(path .. f)()
		table.insert(items, d)
	end
end

function Files.draw()
	Slab.BeginWindow("files", {
		Title = "Files"
	})
	if Slab.Button("reload") then
		tablex.clear(list)
		tablex.clear(items)
		Files.get_items()
	end
	Slab.Separator()

	local index, dir
	for i, v in ipairs(items) do
		if Slab.Button(v.metadata.name) then
			local file = list[i]
			Editor.open_level(path .. file)
		end
		Slab.SameLine()
		if Slab.Button("^", {W = 32}) then
			index = i
			dir = -1
		end

		Slab.SameLine()
		if Slab.Button("v", {W = 32}) then
			index = i
			dir = 1
		end
	end

	if index then
		local item = table.remove(items, index)
		if index + dir > #items + 1 then
			table.insert(items, 1, item)
		elseif index + dir <= 0 then
			table.insert(items, #items + 1, item)
		else
			table.insert(items, index + dir, item)
		end
	end

	Slab.EndWindow()
end

Files.get_items()

return Files
