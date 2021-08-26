local flux = require "source.lib.flux"
local Transition = require "source.transition"

local menu = {}
local title_font = love.graphics.newFont("assets/RobotoCondensed-Regular.ttf", 48)
local menu_font = love.graphics.newFont("assets/RobotoCondensed-Regular.ttf", 32)

local title = love.graphics.newText(title_font, "Sokobomb")
local enter = love.graphics.newText(menu_font, "Press Enter")

function menu:enter()
end

function menu:draw()
    if Transition.flag then
        love.graphics.setShader(Transition.shader)
    end
    love.graphics.draw(title, love.graphics.getWidth() * 1/5, love.graphics.getHeight() * 1/3)
    love.graphics.draw(enter, love.graphics.getWidth() * 1/5, love.graphics.getHeight() * 1/2)
    love.graphics.setShader()
end

function menu:update(dt)
    flux.update(dt)
end

function menu:keypressed(key)
    if key == "return" then
        Transition:fade_in(0.75, function()
            roomy:enter(require "source.game")
        end)
    end
end

return menu
