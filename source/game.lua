local Player = require "source.player"
local Bomb = require "source.bomb"
local Box = require "source.box"
local GameManager = require "source.game_manager"
local Transition = require "source.transition"
local flux = require "source.lib.flux"
local utilities = require "source.utilities"
local Glow = require "source.glow"

local game = {}

function game:enter()
    GameManager:enter(START_LEVEL_NUMBER)
    love.keyboard.setKeyRepeat(true)
end

function game:update(dt)
    flux.update(dt)
end

local draw_interface = require "source.game_interface"
function game:draw()
    local width, height = love.graphics.getDimensions()
    local level = GameManager.level
    local x = width / 2 - (level.width / 2) * TILE_WIDTH - TILE_WIDTH - 4
    local y = height / 2 - (level.height / 2) * TILE_WIDTH - TILE_WIDTH - 4

    draw_interface(GameManager.level_number)

    love.graphics.push()
        love.graphics.translate(x, y)
        level:draw_tiles()
    love.graphics.pop()

    Glow.bloom.glow.x = x
    Glow.bloom.glow.y = y
    Glow.bloom(function()
        level:draw_objects()
    end)
end

function game:keypressed(key)
    if Transition.flag then return end

    if utilities.directions[key] then
        GameManager:turn(utilities.directions[key])
    elseif key == "n" then
        GameManager:go_to_next_level()
    elseif key == "z" then
        GameManager.level:undo()
    elseif key == "r" then
        GameManager:reload()
    elseif key == "escape" then
        love.event.quit()
    elseif key == "`" then
        DEBUG = not DEBUG
    end
end

return game
