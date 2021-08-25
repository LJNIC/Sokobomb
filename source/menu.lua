local menu = {}
local font = love.graphics.newFont("assets/RobotoCondensed-Regular.ttf", 48)
local title = love.graphics.newText(font, "Sokobomb")

function menu:enter()
end

function menu:draw()
    love.graphics.setFont(font)
    love.graphics.draw(title, love.graphics.getWidth() * 1/5, love.graphics.getHeight() * 1/3)
end

function menu:keypressed(key)
    if key == "return" then
        roomy:enter(require "source.game")
    end
end

return menu
