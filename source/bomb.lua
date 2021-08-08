local Base = require "source.base"
local flux = require "source.lib.flux"
local Bomb = Base:extend()

local font = love.graphics.newFont(18)

function Bomb:new(x, y, timer)
    Bomb.super.new(self, x, y)
    self.offset = Vec2(10, 3)
    self.timer = timer
    self.max_timer = timer
    self.alive = true
    self.text = love.graphics.newText(font, tostring(timer))
end

function Bomb:draw()
    love.graphics.setFont(font)
    love.graphics.setLineWidth(2)

    local width, height = self.text:getDimensions()
    love.graphics.draw(self.text, math.floor(self.drawn_position.x + (tile_width / 2 - width / 2)), math.floor(self.drawn_position.y + (tile_width / 2 - height / 2)))

    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.circle("line", self.drawn_position.x + tile_width / 2, self.drawn_position.y + tile_width / 2, tile_width / 2 - 2, 100)
    love.graphics.setColor(1, 1, 1, 1)

    local percent = self.timer / self.max_timer * (2 * math.pi)
    love.graphics.arc("line", "open", self.drawn_position.x + tile_width / 2, self.drawn_position.y + tile_width / 2, tile_width / 2 - 2, 0, percent, 100)
end

function Bomb:tick()
    self.timer = self.timer - 1
    self.text:set(tostring(self.timer))
    if self.timer == 0 then
        self.alive = false
    end
end

return Bomb
