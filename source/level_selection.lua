local Themes = require("source.themes")
local Glow = require "source.glow"
local Transition = require "source.transition"
local Flux = require "source.lib.flux"

local LevelSelection = {}

local levels = require "levels"
local max_level = #levels
local level_items = {}

local COLS = 6
local ROWS
local font = love.graphics.newFont(32)
local font_title = love.graphics.newFont(40)
font:setFilter("nearest", "nearest")
font_title:setFilter("nearest", "nearest")

local levels_palette = {}
local hovered = 1
local highest_level = 1

local w, h = love.graphics.getDimensions()
local canvas = love.graphics.newCanvas(w * 0.5, h * 0.5)

function LevelSelection:enter(previous, save_number)
    hovered = save_number or 1
    highest_level = save_number or highest_level
    tablex.clear(level_items)
    for _, level in ipairs(levels) do
        local d = require("levels/" .. level)
        table.insert(level_items, d)
    end
    ROWS = math.floor(#levels/COLS)

    local themes = Themes.get_palettes_list()
    for i = 1, #levels do
        local palette = tablex.pick_random(themes)
        levels_palette[i] = palette
    end
    Themes.override_levels_palette(levels_palette)
end

function LevelSelection:update(dt)
    Flux.update(dt)
end

function LevelSelection:draw()
    love.graphics.setCanvas(canvas)
        love.graphics.clear()
        love.graphics.push()
        love.graphics.scale(0.5, 0.5)
        self:_draw()
        love.graphics.pop()
    love.graphics.setBlendMode("replace")
    Glow.draw(canvas)

    Transition:draw()
        love.graphics.setBlendMode("alpha")
        love.graphics.push()
        self:_draw()
        love.graphics.pop()
        love.graphics.setBlendMode("lighten", "premultiplied")
        love.graphics.draw(canvas, 0, 0, 0, 2, 2)
    love.graphics.setShader()
    love.graphics.setBlendMode("alpha")
end

function LevelSelection:_draw()
    love.graphics.setLineWidth(2)
    love.graphics.setColor(1, 1, 1, 1)
    local rsize = 64
    local gap = 32

    local w, h = love.graphics.getDimensions()
    local total_w = COLS * rsize + (COLS - 1) * gap
    local total_h = ROWS * rsize + (ROWS - 1) * gap
    local y_offset = 96

    love.graphics.push()

    love.graphics.translate(
        w * 0.5 - total_w * 0.5,
        h * 0.5 - total_h * 0.5 + y_offset)

    love.graphics.setColor(1, 1, 1, 1)
    local hovered_level = level_items[hovered].metadata
    local name = hovered_level.name
    local tw = font_title:getWidth(name)
    love.graphics.setFont(font_title)
    love.graphics.print(name, total_w * 0.5 - tw * 0.5, -y_offset)
    -- love.graphics.rectangle("line", 0, 0, total_w, total_h)

    -- local th = font:getHeight(name)
    -- love.graphics.setColor(1, 0, 0, 1)
    -- love.graphics.rectangle("line", total_w * 0.5 - tw * 0.5, -y_offset, tw, th)
    -- love.graphics.rectangle("line", 0, 0, total_w, total_h)

    love.graphics.setFont(font)
    for y = 1, ROWS do
        for x = 1, COLS do
            local nx = x - 1
            local ny = y - 1
            local level_number = ny * COLS + x
            Themes.on_change_level(level_number)

            local box = Themes.get_color("breakable")
            local text = Themes.get_color("goal")

            local rx = nx * rsize + gap * nx
            local ry = ny * rsize + gap * ny

            love.graphics.setColor(box)
            love.graphics.rectangle("line", rx, ry, rsize, rsize)

            local tx = rx + rsize * 0.5 - font:getWidth(level_number) * 0.5
            local ty = ry + rsize * 0.5 - font:getHeight(level_number) * 0.5

            love.graphics.setColor(text)
            love.graphics.print(level_number, tx, ty)

            if level_number > highest_level then
                --locked
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.line(rx, ry, rx + rsize, ry + rsize)
                love.graphics.line(rx + rsize, ry, rx, ry + rsize)
            end

            if level_number == hovered then
                local hover_gap = 1
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.rectangle("line",
                    rx - hover_gap, ry - hover_gap,
                    rsize + hover_gap * 2, rsize + hover_gap * 2)
            end
        end
    end
    love.graphics.pop()
end

function LevelSelection:keypressed(key)
    local dx, dy = 0, 0
    if key == "left" then
        dx = -1
    elseif key == "right" then
        dx = 1
    elseif key == "up" then
        dy = -1
    elseif key == "down" then
        dy = 1
    elseif key == "return" then
        if hovered <= highest_level then
            Transition:fade_in(0.75, function()
                roomy:enter(require "source.game", hovered)
            end)
        end
    end

    if dx or dy then
        hovered = hovered + (dy * COLS) + dx
        hovered = mathx.wrap(hovered, 1, max_level)
    end
end

return LevelSelection
