local Cell = require("source.cell")

local insert = table.insert

local Level = class()

function Level:new(data)
	tablex.copy(data, self)
	self.orig_filename = self.filename
	self.orig_name = self.name
	self.cells = {}
	print("new level created:")
	pretty.print(self)
end

function Level:serialize()
	local data = {
		metadata = {
			filename = self.filename,
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

function Level:to_1d(t2d)
	local t = {}
	for y = 1, #t2d do
		for x = 1, #t2d[y] do
			local cell = t2d[y][x]
			insert(t, cell)
		end
	end
	return t
end

function Level:to_2d()
	local t = {}
	for y = 1, self.rows do
		t[y] = {}
		for x = 1, self.cols do
			local i = ((y - 1) * self.cols) + x
			local cell = self.cells[i]
			t[y][x] = cell
		end
	end
	return t
end

function Level:resize(t, ox, oy, nw, nh)
	ox = ox or 1
	oy = oy or 1
	local dx = nw - self.cols
	local dy = nh - self.rows
	local nt = {}
	for y = 1, self.rows + dy do
		local yt = {}
		for x = 1, self.cols + dx do
			if t[oy + y] and t[oy + y][ox + x] then
				insert(yt, t[oy + y][ox + x])
			else
				insert(yt, Cell(x, y, self.tile_size))
			end
		end
		insert(nt, yt)
	end

	assert(#nt[1] == nw, "resized width does not match target width. Problem with computation")
	assert(#nt == nh, "resized height does not match target height. Problem with computation")
	return nt
end

return Level
