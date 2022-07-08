local Player = require "source.player"
local Bomb = require "source.bomb"
local Box = require "source.box"
local GameManager = require "source.game_manager"
local Transition = require "source.transition"
local flux = require "source.lib.flux"
local tick = require "source.lib.tick"
local utilities = require "source.utilities"
local Glow = require "source.glow"
local audio = require "source.audio"

local game = {}

local w, h = love.graphics.getDimensions()
local canvas = love.graphics.newCanvas(w * 0.5, h * 0.5)

function game:enter(previous, start_level_number)
    GameManager:enter(start_level_number)
    love.keyboard.setKeyRepeat(true)
    audio.play("game")
end

local buffer = -1
function game:update(dt)
    flux.update(dt)
    tick.update(dt)
    audio.update(dt)
    GameManager.level:update(dt)
    if buffer > -1 and buffer < 0.2 then
        buffer = buffer + dt
    end
end

local draw_interface = require "source.game_interface"
function game:draw()
    local width, height = love.graphics.getDimensions()
    local level = GameManager.level
    local zoom = level.zoom or 1
    local factor = 2 * zoom

    local x = width / factor - (level.width / factor) * TILE_WIDTH * zoom - TILE_WIDTH - 4
    local y = height / factor - (level.height / factor) * TILE_WIDTH * zoom - TILE_WIDTH - 4

    love.graphics.setCanvas(canvas)
        love.graphics.clear()
        love.graphics.push()
        love.graphics.scale(0.5, 0.5)
        love.graphics.translate(x, y)
        level:draw_tiles()
        level:draw_objects()
        love.graphics.pop()
    love.graphics.setBlendMode("replace")
    Glow.draw(canvas)

    Transition:draw()
        draw_interface(GameManager.level_number, GameManager.level)
        love.graphics.setBlendMode("alpha")
        love.graphics.push()
        love.graphics.scale(zoom, zoom)
        love.graphics.translate(x, y)
        level:draw_tiles()
        level:draw_objects()
        love.graphics.pop()
        love.graphics.setBlendMode("lighten", "premultiplied")

        love.graphics.push()
        love.graphics.scale(zoom, zoom)
        love.graphics.draw(canvas, 0, 0, 0, 2, 2)
        love.graphics.pop()
    love.graphics.setShader()
    love.graphics.setBlendMode("alpha")
end

function game:keypressed(key, scancode, is_repeat)
    -- if we're transitioning between levels
    if Transition.flag then return end

    -- if we're resetting a level
    if GameManager.level.resetting then return end

    if utilities.directions[key] then
        if not is_repeat or buffer > 0.1 then
            GameManager:turn(utilities.directions[key])
            buffer = 0
        end
    elseif key == "n" then
        GameManager:enter(GameManager.level_number + 1)
    elseif key == "z" then
        GameManager.level:undo()
    elseif key == "r" and love.keyboard.isDown("lctrl") then
        love.event.quit("restart")
    elseif key == "r" then
        GameManager:reload()
    elseif key == "escape" then
        audio.pause("game", 0.75)
        Transition:fade_in(0.75, function()
            roomy:enter(require "source.menu", 1)
            GameManager:reload()
        end)
    elseif key == "`" then
        DEBUG = not DEBUG
    elseif key == "e" then
        local level = GameManager.level
        if level then
            for _, o in ipairs(level.objects) do
                if o:is(Bomb) then
                    o:create_explosion()
                    break
                end
            end
        end
    end
end

local buttons_to_keys = {
    a = "z",
    b = "r",
    dpup = "up",
    dpdown = "down",
    dpleft = "left",
    dpright = "right",
}
function game:gamepadpressed(joystick, button)
    self:keypressed(buttons_to_keys[button])
end

return game
