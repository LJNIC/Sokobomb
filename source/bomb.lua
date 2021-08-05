local Object = require "source.lib.classic"
local Bomb = Object:extend()

local font = love.graphics.newFont(28)

function Bomb:new(x, y, timer)
    self.position = Vec2(x, y)
    self.timer = timer
end

function Bomb:draw()
    love.graphics.setFont(font)
    love.graphics.print(self.timer, tileWidth * self.position.x + 7, tileWidth * self.position.y)
end

return Bomb
