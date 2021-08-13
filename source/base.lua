local Object = require "source.lib.classic"
local flux = require "source.lib.flux"

local Base = Object:extend()

function Base:new(x, y)
    self.position = Vec2(x, y)
    self.drawn_position = TILE_WIDTH * self.position
    self.moving = false
    self.alive = true
end

function Base:tick()
end

function Base:move(new_position)
    self.position = new_position
    local new_drawn_position = new_position * TILE_WIDTH
    flux.to(self.drawn_position, 0.2, {x = new_drawn_position.x, y = new_drawn_position.y}):oncomplete(function() self.moving = false end)
    self.moving = true
end

function Base:undo(other)
    self:move(other.position)
    self.alive = other.alive
end

function Base:copy()
    local copy = Base(self.position.x, self.position.y)
    return copy
end

function Base:__tostring()
    return self.position:__tostring()
end

return Base
