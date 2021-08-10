local Base = require "source.base"

local Box = Base:extend()

function Box:new(x, y)
    Box.super.new(self, x, y)
    self.offset = Vec2(4, 4)
    self.width = 24
    self.alive = true
    self.movable = true
end

function Box:draw()
    local corner = self.drawn_position + self.offset
    love.graphics.line(corner.x, corner.y, corner.x + self.width, corner.y + self.width)
    love.graphics.line(corner.x + self.width, corner.y, corner.x, corner.y + self.width)
    love.graphics.rectangle("line", corner.x, corner.y, self.width, self.width)
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
