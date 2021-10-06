local Themes = require("source.themes")

local LevelSelection = {}

local levels = require "levels"
local max_level = #levels
local level_items = {}

local COLS = 4
local ROWS
local font = love.graphics.newFont(16)
local font_title = love.graphics.newFont(24)
font:setFilter("nearest", "nearest")
font_title:setFilter("nearest", "nearest")

local levels_palette = {}
local hovered = 1

function LevelSelection:enter(previous, save_number)
    hovered = save_number or 1
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

function LevelSelection:draw()
    love.graphics.setLineWidth(2)
    love.graphics.setColor(1, 1, 1, 1)
    local rsize = 64
    local gap = 32

    local w, h = love.graphics.getDimensions()
    local total_w = COLS * rsize + (COLS - 1) * gap
    local total_h = ROWS * rsize + (ROWS - 1) * gap
    local y_offset = 64

    love.graphics.push()

    love.graphics.translate(
        w * 0.5 - total_w * 0.5,
        h * 0.5 - total_h * 0.5 + y_offset)

    love.graphics.setColor(1, 1, 1, 1)
    local name = level_items[hovered].metadata.name
    local tw = font:getWidth(name)
    love.graphics.setFont(font_title)
    love.graphics.print(name, total_w * 0.5 - tw * 0.5, -y_offset)
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

            if level_number == hovered then
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.rectangle("line", rx, ry, rsize, rsize)
            end
        end
    end
    love.graphics.pop()
end

return LevelSelection
