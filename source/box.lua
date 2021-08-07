local Base = require "source.base"

local Box = Base:extend()

function Box:new(x, y)
    Box.super.new(self, x, y)
    self.offset = Vec2(4, 4)
    self.width = 24
end

function Box:draw()
    local corner = self.drawn_position + self.offset
    love.graphics.line(corner.x, corner.y, corner.x + self.width, corner.y + self.width)
    love.graphics.line(corner.x + self.width, corner.y, corner.x, corner.y + self.width)
    love.graphics.rectangle("line", corner.x, corner.y, self.width, self.width)
end

return Box
