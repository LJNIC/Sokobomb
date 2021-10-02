local NativeFS = require("lib.nativefs")
local Serpent = require("lib.serpent.src.serpent")
local Slab = require("lib.Slab")

local Editor = require("source.editor")

local insert = table.insert
local max = math.max

local Files = {}

local list = {}
local items = {}
local root = NativeFS.getWorkingDirectory()
local path = root .. "/levels/"
local widest = 0
local edit = {
	flag = false,
	item = nil,
	index = 0,
}
local backup = {}

local function reset_edit()
	edit.flag = false
	edit.metadata = nil
	edit.index = 0
end

function Files.get_items()
	local ref = root .. "/levels.lua"
	local ref_t
	if NativeFS.getInfo(root) then
		ref_t = NativeFS.load(ref)()
		print("found levels.lua")
	end

	local style = Slab.GetStyle()
	list = NativeFS.getDirectoryItems(path)

	if ref_t then
		local temp = {}
		for i, v in ipairs(ref_t) do
			for j, v2 in ipairs(list) do
				if stringx.starts_with(v2, v) then
					table.insert(temp, v2)
					table.remove(list, j)
					break
				end
			end
		end
		if #list ~= 0 then
			temp = tablex.append(temp, list)
		end
		list = temp
	end

	for i, f in ipairs(list) do
		local d = NativeFS.load(path .. f)()
		local name = d.metadata.name
		local length = #name * style.FontSize * 0.75
		widest = max(widest, length)
		insert(items, d)
		backup[i] = tablex.copy(d.metadata, {})
	end
end

function Files.draw()
	Slab.BeginWindow("files", {
		Title = "Files",
		AutoSizeWindow = false,
	})
	if Slab.Button("reload") then
		tablex.clear(list)
		tablex.clear(items)
		tablex.clear(backup)
		reset_edit()
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
		pretty.print(serialized)
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

		Slab.SameLine()
		if Slab.Button("edit", {W = 36}) then
			edit.flag = true
			edit.metadata = tablex.copy(v.metadata, {})
			edit.index = i
		end

		if edit.flag and i == edit.index then
			Slab.Indent()
			Slab.Text("Name:")
			Slab.SameLine()
			if Slab.Input("name", {
				ReturnOnText = true,
				Text = edit.metadata.name,
			}) then
				edit.metadata.name = Slab.GetInputText()
			end

			Slab.Text("Zoom:")
			Slab.SameLine()
			if Slab.InputNumberDrag("zoom", edit.metadata.zoom, 1, 128, 0.1) then
				edit.metadata.zoom = Slab.GetInputNumber()
			end

			if Slab.Button("Apply") then
				v.metadata = edit.metadata
			end

			Slab.SameLine()
			if Slab.Button("Revert") then
				v.metadata = backup[i]
				edit.metadata = tablex.copy(backup[i], {})
			end

			local can_save = backup[i] == nil
				or (v.metadata.name == backup[i].name)
				and (v.metadata.zoom == backup[i].zoom)
			Slab.SameLine()
			if Slab.Button("Save", {
				Disabled = can_save,
			}) then
				Files.overwrite_metadata()
			end

			Slab.Unindent()
			Slab.Separator()
		end
	end

	if index then
		local item = table.remove(items, index)
		local new_index = mathx.wrap(index + dir, 1, #items + 2)
		insert(items, new_index, item)

		local b_item = table.remove(backup, index)
		insert(backup, new_index, b_item)

		local l_item = table.remove(list, index)
		insert(list, new_index, l_item)

		reset_edit()
	end

	Slab.EndWindow()
end

function Files.overwrite_metadata()
	if not edit.flag then return end
	local base = NativeFS.getWorkingDirectory() .. "/levels/"
	local data = items[edit.index]
	data.metadata = edit.metadata
	local filename = base .. data.metadata.filename .. ".lua"
	local serialized = Serpent.dump(data)
	local success, message = NativeFS.write(filename, serialized)
	print("overwrite metadata:", success, message)
	pretty.print(serialized)
end

Files.get_items()

return Files
