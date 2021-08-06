local Object = require "source.lib.classic"
local Player = Object:extend()

function Player:new(x, y)
    self.position = Vec2(x or 1, y or 1)
    self.width = 30
    self.increasing = true
end

function Player:update(dt)
end

function Player:draw()
    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line", tile_width * self.position.x + 2, tile_width * self.position.y + 2, self.width, self.width)
end

return Player
