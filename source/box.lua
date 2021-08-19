local flux = require "source.lib.flux"
local Base = require "source.base"

local Box = Base:extend()
Box.offset = Vec2(4, 4)
Box.width = 24

function Box:new(x, y)
    Box.super.new(self, x, y)
    self.alive = true
    self.movable = true
end

function Box:draw(tile_at)
    local cornerX, cornerY = self.drawn_position.x + Box.offset.x, self.drawn_position.y + Box.offset.y
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", cornerX, cornerY, Box.width, Box.width)

    if tile_at == "goal" then
        love.graphics.setColor(0.4, 1, 0.6)
    else 
        love.graphics.setColor(1, 1, 1)
    end

    love.graphics.setLineWidth(4)
    love.graphics.line(cornerX, cornerY, cornerX + Box.width, cornerY + Box.width)
    love.graphics.line(cornerX + Box.width, cornerY, cornerX, cornerY + Box.width)
    love.graphics.rectangle("line", cornerX, cornerY, Box.width, Box.width)
end

function Box:copy()
    local copy = Box(self.position.x, self.position.y)
    copy.alive = self.alive
    return copy
end

return Box
