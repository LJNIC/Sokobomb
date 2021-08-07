local Base = require "source.base"
local flux = require "source.lib.flux"
local Player = Base:extend()

function Player:new(x, y)
    Player.super.new(self, x, y, Vec2(2, 2))
    self.width = 28
    self.moving = false
end

function Player:draw()
    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line", self.drawn_position.x + self.offset.x, self.drawn_position.y + self.offset.y, self.width, self.width)
end

return Player
