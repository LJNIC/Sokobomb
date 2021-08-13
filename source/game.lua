local Player = require "source.player"
local Bomb = require "source.bomb"
local Box = require "source.box"
local GameManager = require "source.game_manager"
local Transition = require "source.transition"
local flux = require "source.lib.flux"
local utilities = require "source.utilities"

local game = {}

function game:enter()
    GameManager:enter(1)
    love.keyboard.setKeyRepeat(true)
end

function game:update(dt)
    flux.update(dt)
end

function game:draw()
    local width, height = love.graphics.getDimensions()
    local level = GameManager.level
    local x = width / 2 - (level.width / 2) * TILE_WIDTH - TILE_WIDTH - 4
    local y = height / 2 - (level.height / 2) * TILE_WIDTH - TILE_WIDTH - 4
    Transition.shader:send("translate", {x, y})

    love.graphics.push()
    love.graphics.translate(x, y)

    level:draw()

    love.graphics.pop()
end

function game:keypressed(key)
    if Transition.flag then return end

    if utilities.directions[key] then
        GameManager:turn(utilities.directions[key])
    elseif key == "n" then
        GameManager:go_to_next_level(0)
    elseif key == "z" then
        GameManager.level:undo()
    elseif key == "r" then
        GameManager:reload()
    elseif key == "escape" then
        love.event.quit()
    end
end

return game
