local NativeFS = require("lib.nativefs")
local Serpent = require("lib.serpent.src.serpent")
local Slab = require("lib.Slab")

local Editor = require("source.editor")

local insert = table.insert
local max = math.max

local Files = {}

local list = {}
local items = {}
local path = NativeFS.getWorkingDirectory() .. "/levels/"
local widest = 0

function Files.get_items()
	list = NativeFS.getDirectoryItems(path)
	for _, f in ipairs(list) do
		local d = NativeFS.load(path .. f)()
		local name = d.metadata.name
		widest = max(widest, #name)
		insert(items, d)
	end

	local style = Slab.GetStyle()
	widest = widest * style.FontSize
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

	Slab.SameLine()
	if Slab.Button("export") then
		local list = {}
		for i, v in ipairs(items) do
			insert(list, v.metadata.filename)
		end
		local serialized = Serpent.dump(list, {
			indent = "\t",
			compact = false,
		})
		local success, message = NativeFS.write("levels.lua", serialized)
		print("export:", success, message)
	end

	Slab.Separator()
	local index, dir
	for i, v in ipairs(items) do
		if Slab.Button(v.metadata.name, {W = widest}) then
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
		local new_index = mathx.wrap(index + dir, 1, #items + 2)
		insert(items, new_index, item)
	end

	Slab.EndWindow()
end

Files.get_items()

return Files
