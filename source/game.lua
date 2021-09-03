local Player = require "source.player"
local Bomb = require "source.bomb"
local Box = require "source.box"
local GameManager = require "source.game_manager"
local Transition = require "source.transition"
local flux = require "source.lib.flux"
local utilities = require "source.utilities"
local Pulse = require "source.pulse"

local game = {}

local canvas = love.graphics.newCanvas()
local glowy_bits = love.graphics.newCanvas()
local glowy_shader = love.graphics.newShader("shaders/glow.glsl")
local GLOW_AMOUNT = 2

function game:enter(previous, start_level_number)
    GameManager:enter(start_level_number)
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
        love.graphics.push()
        love.graphics.translate(x, y)
        level:draw_tiles()
        level:draw_objects()
        love.graphics.pop()
    love.graphics.setShader(glowy_shader)
    for i = 1, GLOW_AMOUNT do
        love.graphics.setCanvas(glowy_bits)
        love.graphics.clear()
        love.graphics.draw(canvas)
        glowy_bits, canvas = canvas, glowy_bits
    end
    love.graphics.setShader()
    love.graphics.setCanvas()

    Transition:draw()
        draw_interface(GameManager.level_number)
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
        GameManager:go_to_next_level(1)
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
    end
end

return game
