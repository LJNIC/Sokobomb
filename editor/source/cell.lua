local Cell = class()

local format = string.format

local fnt = love.graphics.newFont(10)
fnt:setFilter("nearest", "nearest")

function Cell:new(x, y, tile_size)
	self.x = x
	self.y = y
	self.tile_size = tile_size
	self.px = self.x * self.tile_size
	self.py = self.y * self.tile_size
	self.hovered = false
	self.tile = nil
end

function Cell:set_tile(tile, fnt)
	self.fnt = fnt
	self.tile = tile
end

function Cell:draw(line)
	local prev_fnt = love.graphics.getFont()
	local mode = line and "line" or "fill"
	love.graphics.rectangle(mode, self.px, self.py, self.tile_size, self.tile_size)

	if self.tile then
		love.graphics.setFont(self.fnt)
		local fw = self.fnt:getWidth(self.tile.symbol)
		local fh = self.fnt:getHeight()
		love.graphics.setColor(self.tile.color)
		love.graphics.print(self.tile.symbol,
			self.px + self.tile_size * 0.5,
			self.py + self.tile_size * 0.5,
			0, 1, 1, fw * 0.5, fh * 0.5
		)
	end

	if self.hovered then
		local str = format("%d, %d", self.x, self.y)
		love.graphics.setFont(fnt)
		love.graphics.print(str, self.px, self.py)
	end
	love.graphics.setFont(prev_fnt)
end

function Cell:is_hovered(mx, my)
	self.hovered = mx > self.px and mx < self.px + self.tile_size and
		my > self.py and my < self.py + self.tile_size
	return self.hovered
end

return Cell
