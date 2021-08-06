local Dialog = require("source.dialog")

local Cell = class()

local format = string.format
local min = math.min

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
	self.tile = tablex.copy(tile, {})

	if self.tile.is_bomb then
		Dialog.open_bomb_timer(self)
	end
end

function Cell:remove_tile()
	self.fnt = nil
	self.tile = nil
end

function Cell:draw(line)
	local prev_fnt = love.graphics.getFont()
	local mode = line and "line" or "fill"
	love.graphics.rectangle(mode, self.px, self.py, self.tile_size, self.tile_size)

	if self.tile then
		love.graphics.setFont(self.fnt)
		local str = self.tile.symbol
		if self.tile.is_bomb then
			str = str .. self.tile.timer
		end
		local fw = self.fnt:getWidth(str)
		local fh = self.fnt:getHeight()
		local scale = min((self.tile_size/fw), (self.tile_size/fh))
		love.graphics.setColor(self.tile.color)
		love.graphics.print(str,
			self.px + self.tile_size * 0.5,
			self.py + self.tile_size * 0.5,
			0, scale, scale, fw * 0.5, fh * 0.5
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
