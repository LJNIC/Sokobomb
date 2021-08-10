local Base = require "source.base"

local Box = Base:extend()
Box.offset = Vec2(4, 4)
Box.width = 24

function Box:new(x, y)
    Box.super.new(self, x, y)
    self.alive = true
    self.movable = true
end

function Box:draw()
    local cornerX, cornerY = self.drawn_position.x + Box.offset.x, self.drawn_position.y + Box.offset.y
    love.graphics.line(cornerX, cornerY, cornerX + Box.width, cornerY + Box.width)
    love.graphics.line(cornerX + Box.width, cornerY, cornerX, cornerY + Box.width)
    love.graphics.rectangle("line", cornerX, cornerY, Box.width, Box.width)
end

function Box:undo(other_box)
    self.alive = other_box.alive
    self:move(other_box.position)
end

function Box:copy()
    local copy = Box(self.position.x, self.position.y)
    copy.alive = self.alive
    return copy
end

return Box
