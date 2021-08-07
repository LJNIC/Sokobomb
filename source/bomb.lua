local Object = require "source.lib.classic"
local flux = require "source.lib.flux"
local Bomb = Object:extend()

local font = love.graphics.newFont(28)

function Bomb:new(x, y, timer)
    self.position = Vec2(x, y)
    self.drawn_position = tile_width * self.position
    self.offset = Vec2(7, 0)
    self.timer = timer
end

function Bomb:move(new_position)
    self.position = new_position
    local new_drawn_position = new_position * tile_width
    flux.to(self.drawn_position, 0.2, {x = new_drawn_position.x, y = new_drawn_position.y}):oncomplete(function() self.moving = false end)
end

function Bomb:draw()
    love.graphics.setFont(font)
    love.graphics.print(self.timer, self.drawn_position.x + self.offset.x, self.drawn_position.y + self.offset.y)
end

function Bomb:tick()
    self.timer = self.timer - 1
end

return Bomb
