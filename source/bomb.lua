local Base = require "source.base"
local flux = require "source.lib.flux"
local directions = require("source.utilities").directions
local Pulse = require "source.pulse"

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
    self.opacity = 1
    self.pulse = Pulse()
    self.explosions = {}
end

function Bomb:draw()
    love.graphics.setFont(font)
    love.graphics.setLineWidth(2)

    if self.infinite then
        self.text:set("∞")
    else
        self.text:set(tostring(math.round(math.max(self.tween_timer, 1))))
    end

    self.pulse:set_color(0.5, 0.5, 0.5, self.opacity)
    love.graphics.circle("line", self.drawn_position.x + TILE_WIDTH / 2, self.drawn_position.y + TILE_WIDTH / 2, TILE_WIDTH / 2 - 2, 100)

    local width, height = self.text:getDimensions()
    self.pulse:set_color(227/255, 52/255, 0, self.opacity)
    love.graphics.draw(self.text, math.floor(self.drawn_position.x + (TILE_WIDTH / 2 - width / 2)), math.floor(self.drawn_position.y + (TILE_WIDTH / 2 - height / 2)))

    local percent = self.infinite and (2 * math.pi) or (self.tween_timer / self.max_timer * (2 * math.pi))
    love.graphics.arc("line", "open", self.drawn_position.x + TILE_WIDTH / 2, self.drawn_position.y + TILE_WIDTH / 2, TILE_WIDTH / 2 - 2, 0, percent, 100)

    love.graphics.setColor(1, 1, 1)

    self:draw_explosions()
end

function Bomb:tick(objects)
    if self.infinite then return end

    self.timer = self.timer - 1
    self.tweener = flux.to(self, 0.2, {tween_timer = self.timer})
end

function Bomb:explode(objects, player)
    flux.to(self, 0.2, {opacity = 0}):oncomplete(function() self.alive = false end)
    for _, direction in pairs(directions) do
        local to_explode = self.position + direction

        if player.position == to_explode then
            player.alive = false
        end

        for _, object in ipairs(objects) do
            if object.alive and object.position == to_explode then
                if object:is(Bomb) and object.timer > 1 then
                    object:explode_self()
                elseif not object:is(Bomb) then
                    object.alive = false
                end
            end
        end
    end

    self:create_explosion()
end

function Bomb:explode_self()
    self.infinite = false
    if self.tweener then self.tweener:stop() end
    flux.to(self, 0.2, {tween_timer = 1})
    self.timer = 1
end

function Bomb:create_explosion()
    local n = love.math.random(12, 20)
    local q = TILE_WIDTH * 0.25

    local x = self.drawn_position.x + TILE_WIDTH_H
    local y = self.drawn_position.y + TILE_WIDTH_H
    local d = q * 3
    local dirs = {
        {0, -d}, --n
        {0, d}, --s
        {-d, 0}, --w
        {d, 0}, --e
    }
    local dir = 1

    --if uniform size and alpha for each direction
    local ts = love.math.random(q, TILE_WIDTH_H)

    for i = 1, n do
        dir = dir + 1
        if dir > 4 then
            dir = 1
        end

        local offset = dirs[dir]
        local e = {
            x = x, y = y, s = 0, a = 0,
            tx = x + offset[1],
            ty = y + offset[2],

            --if uniform size and alpha for each direction
            ts = ts,
            ta = 1,

            --if random size and alpha for each direction
            -- ts = love.math.random(q, TILE_WIDTH_H),
            -- ta = love.math.random(),
        }
        table.insert(self.explosions, e)
    end

    local dur_in = 0.25
    local dur_out = 0.25
    for _, e in ipairs(self.explosions) do
        flux.to(e, dur_in, {
            x = e.tx,
            y = e.ty,
            s = e.ts,
            a = e.ta,
        })
        :ease("backout")
        :oncomplete(function()
            flux.to(e, dur_out, {
                s = 0,
                a = 0,
            }):oncomplete(function()
                e.remove = true
            end)
        end)
    end
end

function Bomb:draw_explosions()
    if #self.explosions == 0 then return end
    love.graphics.setLineWidth(1)

    local remove = 1
    for _, e in ipairs(self.explosions) do
        love.graphics.setColor(1, 1, 1, e.a)
        love.graphics.circle("fill", e.x, e.y, e.s)

        if e.remove then
            remove = remove + 1
        end
    end

    if remove >= #self.explosions then
        tablex.clear(self.explosions)
    end
end

function Bomb:undo(other_bomb)
    Bomb.super.undo(self, other_bomb)
    self.timer = other_bomb.timer
    self.infinite = other_bomb.infinite
    flux.to(self, 0.2, {tween_timer = other_bomb.timer})
    flux.to(self, 0.2, {opacity = other_bomb.opacity})
end

function Bomb:copy()
    local copy = Bomb(self.position.x, self.position.y, self.timer)
    copy.alive = self.alive
    copy.infinite = self.infinite

    return copy
end

return Bomb
