local Object = require "source.lib.classic"
local flux = require "source.lib.flux"

local Base = Object:extend()

function Base:new(x, y)
    self.position = Vec2(x, y)
    self.drawn_position = tile_width * self.position
    self.moving = false
end

function Base:move(new_position)
    self.position = new_position
    local new_drawn_position = new_position * tile_width
    flux.to(self.drawn_position, 0.2, {x = new_drawn_position.x, y = new_drawn_position.y}):oncomplete(function() self.moving = false end)
    self.moving = true
end

return Base
