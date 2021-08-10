local Player = require "source.player"
local Bomb = require "source.bomb"
local Box = require "source.box"
local GameManager = require "source.game_manager"
local Transition = require "source.transition"
local flux = require "source.lib.flux"
local game = {}

love.keyboard.setKeyRepeat(true)

function game:enter()
	GameManager:enter(1)
end

function game:update(dt)
    flux.update(dt)
end

function game:draw()
    if Transition.flag then
        love.graphics.setShader(Transition.shader)
    end
    GameManager:draw()
    love.graphics.setShader()
end

function game:keypressed(key)
    if Transition.flag then return end
    GameManager:keypressed(key)
    if key == "r" then
        love.event.quit("restart")
    elseif key == "n" then
        GameManager:go_to_next_level()
    elseif key == "escape" then
        love.event.quit()
    end
end

return game
