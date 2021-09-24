local flux = require "source.lib.flux"
local Transition = require "source.transition"
local GameManager = require "source.game_manager"
local Bomb = require "source.bomb"
local Glow = require "source.glow"

local title_font = love.graphics.newFont("assets/RobotoCondensed-Regular.ttf", 72)
local menu_font = love.graphics.newFont("assets/RobotoCondensed-Regular.ttf", 42)
local music = love.audio.newSource("assets/sokobomb_menu_b.mp3", "stream")
music:setLooping(true)

local title = love.graphics.newText(title_font, "sokobomb")

local menu = {
    selected = 1,
    save_number = 1,
    tween = nil,
    color = 1,
    color_tween = nil,
    angle = 0,
    canvas = love.graphics.newCanvas()
}

local new = {
    text = love.graphics.newText(menu_font, "new game"),
    action = function()
        love.filesystem.write("save.txt", 1)
        roomy:enter(require "source.game", 1)
    end
}
local continue = {
    text = love.graphics.newText(menu_font, "continue"),
    action = function()
        roomy:enter(require "source.game", menu.save_number)
    end
}
local exit = {
    text = love.graphics.newText(menu_font, "exit"),
    action = function() love.event.quit() end
}
menu.actions = { new, exit }

function menu:enter()
    love.audio.play(music)
    local save = love.filesystem.read("save.txt")
    if save then
        menu.save_number = tonumber(save)
        table.insert(self.actions, 1, continue)
    end
end

function menu:draw()
    Transition:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(title, (love.graphics.getWidth() * 1/3) - title:getWidth(), love.graphics.getHeight() * 1/4)

    love.graphics.setLineWidth(30)
    local ww, wh = love.graphics.getDimensions()
    love.graphics.setColor(self.color * 227/255, self.color * 52/255, 0)

    local radius = ww / 5
    love.graphics.circle('line', ww * 2/3, wh / 2, radius)

    love.graphics.setColor(1,1,1)

    for i, action in ipairs(self.actions) do
        love.graphics.push()
        love.graphics.translate(ww * 2/3, wh/2)
        love.graphics.rotate(((i-1) * -math.pi/8) + self.angle)
        love.graphics.translate(-ww * 2/3, -wh/2)

        local twidth = action.text:getWidth()
        if i ~= self.selected then
            love.graphics.setColor(1, 1, 1, 0.5)
        else
            love.graphics.setColor(1, 1, 1, 1)
        end
        local offset = action == exit and 0 or 30
        love.graphics.draw(action.text, ww * 2/3 - radius - twidth + offset, wh / 2 - action.text:getHeight() / 2)
        love.graphics.pop()
    end
end

function menu:update(dt)
    flux.update(dt)
end

function menu:select(index)
    self.selected = index

    if self.tween then
        self.tween:stop()
        self.color_tween:stop()
    end

    self.tween = flux.to(self, 0.4, { angle = (self.selected - 1) * math.pi / 8 })
    self.color_tween = flux.to(self, 0.2, { color = 0.4 }):oncomplete(function()
        flux.to(self, 0.2, { color = 1 })
    end)
end

function menu:keypressed(key)
    if key == "down" then
        self:select(math.wrap(self.selected + 1, 1, #self.actions + 1))
    elseif key == "up" then
        self:select(math.wrap(self.selected - 1, 1, #self.actions + 1))
    elseif key == "return" then
        local action = self.actions[self.selected]
        Transition.text = (action == exit and "") or GameManager.levels[(action == continue and self.save_number) or 1].name
        Transition:fade_in(0.75, function()
            action.action()
        end, nil, function(percent) music:setVolume(math.abs(percent - 1)) end)
    end
end

local buttons_to_key = {
    dpup = "up",
    dpdown = "down",
    a = "return",
    b = "return"
}
function menu:gamepadpressed(joystick, button)
    self:keypressed(buttons_to_key[button])
end

return menu
