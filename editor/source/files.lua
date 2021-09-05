local NativeFS = require("lib.nativefs")
local Slab = require("lib.Slab")

local Editor = require("source.editor")

local Files = {}

local list = {}
list = NativeFS.getDirectoryItems("../levels/")

function Files.draw()
	Slab.BeginWindow("files", {
		Title = "Files"
	})
	if Slab.Button("reload") then
		list = NativeFS.getDirectoryItems("../levels/")
	end
	Slab.Separator()

	for _, f in ipairs(list) do
		if Slab.Button(f) then
			Editor.open_level("../levels/" .. f)
		end
	end
	Slab.EndWindow()
end

return Files
