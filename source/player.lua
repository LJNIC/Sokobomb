local Object = require "source.lib.classic"
local Player = Object:extend()

function Player:new(x, y)
    self.position = Vec2(x or 1, y or 1)
    self.width = 24
    self.increasing = true
end

function Player:update(dt)
    if self.increasing and self.width > 32 then
        self.increasing = false
    elseif not self.increasing and self.width < 24 then
        self.increasing = true
    end
    self.width = self.increasing and self.width + (5 * dt) or self.width - (5 * dt)
end

function Player:draw()
    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line", tileWidth * self.position.x, tileWidth * self.position.y, self.width, self.width)
end

return Player
