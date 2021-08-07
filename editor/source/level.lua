local insert = table.insert

local Level = class()

function Level:new(data)
	tablex.copy(data, self)
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
		tiles = {},
		bombs = {},
		player = {},
		boxes = {},
	}

	for _, c in ipairs(self.cells) do
		local d, kind = c:serialize()
		insert(data[kind], d)
	end

	return data
end

return Level
