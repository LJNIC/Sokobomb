local flux = require "source.lib.flux"
local Transition = require "source.transition"

local menu = {}
local title_font = love.graphics.newFont("assets/RobotoCondensed-Regular.ttf", 48)
local menu_font = love.graphics.newFont("assets/RobotoCondensed-Regular.ttf", 32)

local title = love.graphics.newText(title_font, "sokobomb")

local save_number

local new = { 
    text = love.graphics.newText(menu_font, "new game"),
    action = function() 
        love.filesystem.write("save.txt", 1)
        roomy:enter(require "source.game") 
    end
}
local continue = {
    text = love.graphics.newText(menu_font, "continue"),
    action = function() 
        START_LEVEL_NUMBER = save_number
        roomy:enter(require "source.game") 
    end
}
local exit = {
    text = love.graphics.newText(menu_font, "exit"),
    action = function() love.event.quit() end
}

local actions = { new, exit }

local selected = 1


function menu:enter()
    local save = love.filesystem.read("save.txt")
    if save then
        save_number = tonumber(save)
        table.insert(actions, 1, continue)
    end
end

function menu:draw()
    if Transition.flag then
        love.graphics.setShader(Transition.shader)
    end

    for i, action in ipairs(actions) do
        if selected == i then
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.setColor(0.5, 0.5, 0.5)
        end

        love.graphics.draw(action.text, love.graphics.getWidth() * 1/5, love.graphics.getHeight() * 1/2 + 50*i)
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(title, love.graphics.getWidth() * 1/5, love.graphics.getHeight() * 1/3)
    love.graphics.setShader()
end

function menu:update(dt)
    flux.update(dt)
end

function menu:keypressed(key)
    if key == "down" then
        selected = math.wrap(selected + 1, 1, #actions + 1)
    elseif key == "up" then
        selected = math.wrap(selected - 1, 1, #actions + 1)
    elseif key == "return" then
        Transition:fade_in(0.75, function()
            actions[selected].action()    
        end)
    end
end

return menu
