local Base = require "source.base"
local flux = require "source.lib.flux"
local directions = require("source.utilities").directions

local Bomb = Base:extend()
local font = love.graphics.newFont("assets/RobotoCondensed-Regular.ttf", 18)

function Bomb:new(x, y, timer, is_infinite)
    Bomb.super.new(self, x, y)
    self.offset = Vec2(10, 3)
    self.timer = timer
    self.tween_timer = timer
    self.max_timer = timer
    self.alive = true
    self.movable = true
    self.text = love.graphics.newText(font, tostring(timer))
    self.infinite = is_infinite or false
end

function Bomb:draw()
    love.graphics.setFont(font)
    love.graphics.setLineWidth(2)

    if self.infinite then
        self.text:set("∞")
    else
        self.text:set(tostring(math.round(math.max(self.tween_timer, 1))))
    end

    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.circle("line", self.drawn_position.x + TILE_WIDTH / 2, self.drawn_position.y + TILE_WIDTH / 2, TILE_WIDTH / 2 - 2, 100)

    local width, height = self.text:getDimensions()
    love.graphics.setColor(227/255, 52/255, 0)
    love.graphics.draw(self.text, math.floor(self.drawn_position.x + (TILE_WIDTH / 2 - width / 2)), math.floor(self.drawn_position.y + (TILE_WIDTH / 2 - height / 2)))

    local percent = self.infinite and (2 * math.pi) or (self.tween_timer / self.max_timer * (2 * math.pi))
    love.graphics.arc("line", "open", self.drawn_position.x + TILE_WIDTH / 2, self.drawn_position.y + TILE_WIDTH / 2, TILE_WIDTH / 2 - 2, 0, percent, 100)
end

function Bomb:tick(objects)
    if self.infinite then return end

    if self.timer > 1 then
        self.tweener = flux.to(self, 0.2, {tween_timer = self.tween_timer - 1})
    end
    self.timer = self.timer - 1
end

function Bomb:explode(objects)
    self.alive = false
    for _, direction in pairs(directions) do
        local to_explode = self.position + direction
        for _, object in ipairs(objects) do
            if object.position == to_explode and object ~= self then
                if object:is(Bomb) then
                    object:explode_self()
                else
                    object.alive = false
                end
            end
        end
    end
end

function Bomb:explode_self()
    self.infinite = false
    if self.tweener then self.tweener:stop() end
    flux.to(self, 0.2, {tween_timer = 1})
    self.timer = 1
end

function Bomb:undo(other_bomb)
    Bomb.super.undo(self, other_bomb)
    self.timer = other_bomb.timer
    self.infinite = other_bomb.infinite
    flux.to(self, 0.2, {tween_timer = other_bomb.timer})
end

function Bomb:copy()
    local copy = Bomb(self.position.x, self.position.y, self.timer)
    copy.alive = self.alive
    copy.infinite = self.infinite

    return copy
end

return Bomb
