local Base = require "source.base"
local Themes = require "source.themes"
local flux = require "source.lib.flux"
local tick = require "source.lib.tick"
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

function Bomb:tick(objects)
    if self.infinite then return end

    self.timer = self.timer - 1
    self.tweener = flux.to(self, 0.2, {tween_timer = self.timer})
end

function Bomb:explode(objects, player)
    self.alive = false
    flux.to(self, 0.8, {opacity = 0})
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

function Bomb:undo(other_bomb)
    Bomb.super.undo(self, other_bomb)
    self.timer = other_bomb.timer
    self.infinite = other_bomb.infinite
    flux.to(self, 0.2, {tween_timer = other_bomb.timer})
    flux.to(self, 0.2, {opacity = 1})
end

function Bomb:copy()
    local copy = Bomb(self.position.x, self.position.y, self.timer)
    copy.alive = self.alive
    copy.infinite = self.infinite

    return copy
end

function Bomb:draw()
    love.graphics.setFont(font)
    love.graphics.setLineWidth(2)

    if self.infinite then
        self.text:set("∞")
    else
        self.text:set(tostring(math.round(math.max(self.tween_timer, 1))))
    end

    -- self.pulse:set_color(0.5, 0.5, 0.5, self.opacity)
    self.pulse:set_color(Themes.get_color_raw("bomb_pulse_outer", self.opacity))
    love.graphics.circle("line", self.drawn_position.x + TILE_WIDTH / 2, self.drawn_position.y + TILE_WIDTH / 2, TILE_WIDTH / 2 - 2, 100)

    local width, height = self.text:getDimensions()
    -- self.pulse:set_color(227/255, 52/255, 0, self.opacity)
    self.pulse:set_color(Themes.get_color_raw("bomb_pulse_inner", self.opacity))
    love.graphics.draw(self.text, math.floor(self.drawn_position.x + (TILE_WIDTH / 2 - width / 2)), math.floor(self.drawn_position.y + (TILE_WIDTH / 2 - height / 2)))

    local percent = self.infinite and (2 * math.pi) or (self.tween_timer / self.max_timer * (2 * math.pi))
    love.graphics.arc("line", "open", self.drawn_position.x + TILE_WIDTH / 2, self.drawn_position.y + TILE_WIDTH / 2, TILE_WIDTH / 2 - 2, 0, percent, 100)

    love.graphics.setColor(1, 1, 1)
end


local distance = TILE_WIDTH * 0.75
local offsets = {
    {0, distance},
    {0, -distance},
    {distance, 0},
    {-distance, 0},
}

local short = distance * 0.75
local diagonals = {
    {short, short},
    {-short, -short},
    {-short, short},
    {short, -short}
}
function Bomb:create_explosion()
    local q = TILE_WIDTH * 0.25

    local x = self.drawn_position.x + TILE_WIDTH_H
    local y = self.drawn_position.y + TILE_WIDTH_H
    local radius = TILE_WIDTH / 2

    for _, offset in ipairs(offsets) do
        local explosion = {
            x = x, 
            y = y, 
            radius = 0, 
            alpha = 0,
            target_x = x + offset[1],
            target_y = y + offset[2],

            --if uniform size and alpha for each direction
            target_radius = radius,
            target_alpha = 1,
            color = Themes.get_color("bomb_pulse_inner", 0)
        }
        table.insert(self.explosions, explosion)
    end

    for _, offset in ipairs(diagonals) do
        local explosion = {
            x = x, 
            y = y, 
            radius = 0, 
            alpha = 0,
            target_x = x + offset[1],
            target_y = y + offset[2],

            --if uniform size and alpha for each direction
            target_radius = radius/2,
            target_alpha = 1,
            color = {1, 1, 1}
        }
        table.insert(self.explosions, explosion)
    end

    local dur_in = 0.25
    local dur_out = 0.5
    for _, explosion in ipairs(self.explosions) do
        flux.to(explosion, dur_in, {
            x = explosion.target_x,
            y = explosion.target_y,
            radius = explosion.target_radius,
            alpha = explosion.target_alpha,
        })
        :ease("backout")
        :oncomplete(function()
            flux.to(explosion, dur_out, {
                radius = 0,
                alpha = 0,
            }):oncomplete(function()
                explosion.remove = true
            end):ease("quadout")
        end)
    end
end

function Bomb:draw_explosions()
    if #self.explosions == 0 then return end
    love.graphics.setLineWidth(1)

    local remove = 1
    for _, explosion in ipairs(self.explosions) do
        Themes.set_color("explosion_inner")
        love.graphics.circle("fill", explosion.x, explosion.y, explosion.radius)

        love.graphics.setColor(explosion.color[1] * explosion.alpha, explosion.color[2] * explosion.alpha, explosion.color[3] * explosion.alpha)
        love.graphics.circle("line", explosion.x, explosion.y, explosion.radius)

        if explosion.remove then
            remove = remove + 1
        end
    end

    love.graphics.setColor(1, 1, 1)

    if remove >= #self.explosions then
        tablex.clear(self.explosions)
    end
end

return Bomb
