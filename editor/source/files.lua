local NativeFS = require("lib.nativefs")
local Serpent = require("lib.serpent.src.serpent")
local Slab = require("lib.Slab")

local Editor = require("source.editor")

local insert = table.insert
local max = math.max

local Files = {}
Files.is_open = true

local list = {}
local items = {}
local path = NativeFS.getWorkingDirectory() .. "/levels/"
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
	list = NativeFS.getDirectoryItems(path)
	for _, f in ipairs(list) do
		local d = NativeFS.load(path .. f)()
		local name = d.metadata.name
		widest = max(widest, #name)
		insert(items, d)
	end

	local style = Slab.GetStyle()
	widest = widest * style.FontSize * 0.75
end

function Files.draw()
	Slab.BeginWindow("files", {
		Title = "Files",
	})
	if Slab.CheckBox(Files.is_open, "Show") then
		Files.is_open = not Files.is_open
	end

	if Files.is_open then
		if Slab.Button("reload") then
			tablex.clear(list)
			tablex.clear(items)
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

				if Slab.Button("Apply") then
					backup[i] = tablex.copy(v.metadata, {})
					v.metadata = edit.metadata
				end

				Slab.SameLine()
				if Slab.Button("Revert") then
					v.metadata = backup[i]
					edit.metadata = tablex.copy(backup[i], {})
				end

				Slab.SameLine()
				if Slab.Button("Save", {
					Disabled = backup[i] == nil or v.metadata.name == backup[i].name
				}) then
					Files.overwrite_metadata(i, edit.metadata)
				end
				Slab.Unindent()
				Slab.Separator()
			end
		end

		if index then
			local item = table.remove(items, index)
			local new_index = mathx.wrap(index + dir, 1, #items + 2)
			insert(items, new_index, item)
			reset_edit()
		end
	end

	Slab.EndWindow()
end

function Files.overwrite_metadata(i, metadata)

end

Files.get_items()

return Files
