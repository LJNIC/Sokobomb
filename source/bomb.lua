local Object = require "source.lib.classic"
local Bomb = Object:extend()

local font = love.graphics.newFont(28)

function Bomb:new(x, y, timer)
    self.position = Vec2(x, y)
    self.timer = timer
end

function Bomb:draw()
    love.graphics.setFont(font)
    love.graphics.print(self.timer, tile_width * self.position.x + 7, tile_width * self.position.y)
end

function Bomb:tick()
    self.timer = self.timer - 1
end

return Bomb
