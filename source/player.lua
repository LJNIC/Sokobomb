local Object = require "source.lib.classic"
local Player = Object:extend()

function Player:new(x, y)
    self.position = Vec2(x or 2, y or 2)
end

function Player:draw()
    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line", tileWidth * self.position.x, tileWidth * self.position.y, tileWidth, tileWidth)
end

return Player
