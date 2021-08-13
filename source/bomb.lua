local Base = require "source.base"
local flux = require "source.lib.flux"
local directions = require("source.utilities").directions

local Bomb = Base:extend()
local font = love.graphics.newFont(18)

function Bomb:new(x, y, timer)
    Bomb.super.new(self, x, y)
    self.offset = Vec2(10, 3)
    self.timer = timer
    self.tween_timer = timer
    self.max_timer = timer
    self.alive = true
    self.movable = true
    self.text = love.graphics.newText(font, tostring(timer))
end

function Bomb:draw()
    love.graphics.setFont(font)
    love.graphics.setLineWidth(2)

    self.text:set(tostring(math.round(math.max(self.tween_timer, 1))))
    local width, height = self.text:getDimensions()
    love.graphics.draw(self.text, math.floor(self.drawn_position.x + (tile_width / 2 - width / 2)), math.floor(self.drawn_position.y + (tile_width / 2 - height / 2)))

    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.circle("line", self.drawn_position.x + tile_width / 2, self.drawn_position.y + tile_width / 2, tile_width / 2 - 2, 100)
    love.graphics.setColor(1, 1, 1, 1)

    local percent = self.tween_timer / self.max_timer * (2 * math.pi)
    love.graphics.arc("line", "open", self.drawn_position.x + tile_width / 2, self.drawn_position.y + tile_width / 2, tile_width / 2 - 2, 0, percent, 100)
end

function Bomb:tick(objects)
    self.timer = self.timer - 1
    flux.to(self, 0.2, {tween_timer = self.tween_timer - 1})
    if self.timer == 0 then
        self:explode(objects)
        self.alive = false
    end
end

function Bomb:explode(objects)
    for _, direction in pairs(directions) do
        local to_explode = self.position + direction
        for _, object in ipairs(objects) do
            if object.position == to_explode then
                object.alive = false
            end
        end
    end
end

function Bomb:undo(other_bomb)
    Bomb.super.undo(self, other_bomb)
    self.timer = other_bomb.timer
    flux.to(self, 0.2, {tween_timer = other_bomb.timer})
end

function Bomb:copy()
    local copy = Bomb(self.position.x, self.position.y, self.timer)
    copy.alive = self.alive

    return copy
end

return Bomb
