local Player = require "source.player"
local Bomb = require "source.bomb"
local Box = require "source.box"
local GameManager = require "source.game_manager"
local Transition = require "source.transition"
local flux = require "source.lib.flux"
local utilities = require "source.utilities"
local Glow = require "source.glow"
local Transition = require "source.transition"
local Pulse = require "source.pulse"

local game = {}

local canvas = love.graphics.newCanvas(love.graphics.getDimensions())

function game:enter()
    GameManager:enter(START_LEVEL_NUMBER)
    love.keyboard.setKeyRepeat(true)
end

local buffer = -1
function game:update(dt)
    flux.update(dt)
    if buffer > -1 and buffer < 0.2 then
        buffer = buffer + dt
    end
end

local draw_interface = require "source.game_interface"
function game:draw()
    local width, height = love.graphics.getDimensions()
    local level = GameManager.level
    local x = width / 2 - (level.width / 2) * TILE_WIDTH - TILE_WIDTH - 4
    local y = height / 2 - (level.height / 2) * TILE_WIDTH - TILE_WIDTH - 4

    love.graphics.setCanvas(canvas)
        love.graphics.clear()
        draw_interface(GameManager.level_number)
        Pulse.tx = x
        Pulse.ty = y
        --use pulse
        love.graphics.push()
        love.graphics.translate(x, y)
        level:draw_tiles()
        level:draw_objects()
        love.graphics.pop()
    love.graphics.setCanvas()

    -- Glow.bloom(function()
    --     level:draw_tiles()
    --     level:draw_objects()
    -- end, x, y, canvas)

    if Transition.flag then
        love.graphics.setShader(Transition.shader)
    end
        love.graphics.draw(canvas)
    love.graphics.setShader()

    if DEBUG then
        love.graphics.print(love.timer.getFPS())
    end
end

function game:keypressed(key, scancode, is_repeat)
    if Transition.flag then return end

    if utilities.directions[key] then
        if not is_repeat or buffer > 0.1 then
            GameManager:turn(utilities.directions[key])
            buffer = 0
        end
    elseif key == "n" then
        GameManager:go_to_next_level(0)
    elseif key == "z" then
        GameManager.level:undo()
    elseif key == "r" and love.keyboard.isDown("lctrl") then
        love.event.quit("restart")
    elseif key == "r" then
        GameManager:reload()
    elseif key == "escape" then
        love.event.quit()
    elseif key == "`" then
        DEBUG = not DEBUG
    elseif key == "t" then
        GameManager.level.player:transition()
    end
end

return game
