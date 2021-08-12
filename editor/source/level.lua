local insert = table.insert

local Level = class()

function Level:new(data)
	tablex.copy(data, self)
	self.orig_name = self.name
	self.cells = {}
	print("new level created:")
	pretty.print(self)
end

function Level:serialize()
	local data = {
		metadata = {
			name = self.name,
			tile_size = self.tile_size,
			cols = self.cols,
			rows = self.rows,
		},
		objects = {},
		tiles = {},
	}

	for _, c in ipairs(self.cells) do
		local n, s, kind = c:serialize()
		if kind == "objects" then
			insert(data.objects, s)
		end
		insert(data.tiles, n)
	end

	return data
end

return Level
