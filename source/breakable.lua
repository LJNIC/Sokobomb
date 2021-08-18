local Base = require "source.base"
local Breakable = Base:extend()

function Breakable:new(x, y)
    Breakable.super.new(self, x, y)
    self.width = 24
    self.offset = Vec2(4, 4)
    self.movable = false
end

function Breakable:draw()
    local corner = self.drawn_position + self.offset
    love.graphics.line(corner.x, corner.y + self.width / 3, corner.x + self.width, corner.y + self.width / 3)
    love.graphics.line(corner.x, corner.y + 2 * self.width / 3, corner.x + self.width, corner.y + 2 * self.width / 3)
    love.graphics.rectangle("line", corner.x, corner.y, self.width, self.width)
end

function Breakable:explode()
end

return Breakable
