local Base = require "source.base"
local flux = require "source.lib.flux"
local Transition = require "source.transition"
local Player = Base:extend()

function Player:new(x, y)
    Player.super.new(self, x, y)
    self.offset = Vec2(4, 4)
    self.width = 24
    self.moving = false
    Transition.shader:send("size", {self.width, self.width})
end

function Player:draw()
    love.graphics.setColor(1, 1, 1, 1)
    if Transition.flag then
        Transition.shader:send("pos", {self.drawn_position.x, self.drawn_position.y})
        love.graphics.setShader(Transition.shader)
    end

    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line", self.drawn_position.x + self.offset.x,
        self.drawn_position.y + self.offset.y, self.width, self.width)

    love.graphics.setShader()
end

function Player:copy()
    return Player(self.position.x, self.position.y)
end

return Player
