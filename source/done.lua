local Transition = require "source.transition"
local done = {}

local font = love.graphics.newFont("assets/RobotoCondensed-Regular.ttf", 32)
local text = love.graphics.newText(font, "hey, you did it!")

function done:draw()
    if Transition.flag then
        love.graphics.setShader(Transition.shader)
    end
    love.graphics.draw(text, love.graphics.getWidth()/2 - text:getWidth()/2, love.graphics.getHeight()/2)
    love.graphics.setShader()
end

return done
