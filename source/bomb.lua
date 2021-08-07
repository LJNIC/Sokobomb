local Base = require "source.base"
local flux = require "source.lib.flux"
local Bomb = Base:extend()

local font = love.graphics.newFont(28)

function Bomb:new(x, y, timer)
    Bomb.super.new(self, x, y)
    self.offset = Vec2(7, 0)
    self.timer = timer
    self.alive = true
end

function Bomb:draw()
    love.graphics.setFont(font)
    love.graphics.print(self.timer, self.drawn_position.x + self.offset.x, self.drawn_position.y + self.offset.y)
end

function Bomb:tick()
    self.timer = self.timer - 1
    if self.timer == 0 then
        self.alive = false
    end
end

return Bomb
