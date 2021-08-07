local Object = require "source.lib.classic"
local flux = require "source.lib.flux"
local Player = Object:extend()

function Player:new(x, y)
    self.position = Vec2(x or 1, y or 1)
    self.drawn_position = self.position * tile_width
    self.offset = Vec2(2, 2)
    self.width = 28
    self.increasing = true
    self.moving = false
end

function Player:move(new_position)
    self.position = new_position
    local new_drawn_position = new_position * tile_width
    flux.to(self.drawn_position, 0.2, {x = new_drawn_position.x, y = new_drawn_position.y}):oncomplete(function() self.moving = false end)
    self.moving = true
end

function Player:draw()
    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line", self.drawn_position.x + self.offset.x, self.drawn_position.y + self.offset.y, self.width, self.width)
end

return Player
