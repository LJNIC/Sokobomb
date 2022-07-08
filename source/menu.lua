local flux = require "source.lib.flux"
local Transition = require "source.transition"
local GameManager = require "source.game_manager"
local Bomb = require "source.bomb"
local Glow = require "source.glow"
local audio = require "source.audio"

local title_font = love.graphics.newFont("assets/RobotoCondensed-Regular.ttf", 72)
local menu_font = love.graphics.newFont("assets/RobotoCondensed-Regular.ttf", 42)
local audio = require "source.audio"

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

local w, h = love.graphics.getDimensions()
local canvas = love.graphics.newCanvas(w * 0.5, h * 0.5)

local function fade_music()
    audio.stop("menu", 0.75)
end

local new = {
    text = love.graphics.newText(menu_font, "new game"),
    action = function()
        Transition.text = GameManager.levels[1].name
        love.filesystem.write("save.txt", 1)
        audio.stop("menu", 1)
        Transition:fade_in(0.75, function()
            roomy:enter(require "source.game", 1)
        end)
    end
}
local continue = {
    text = love.graphics.newText(menu_font, "continue"),
    action = function()
        Transition.text = GameManager.levels[menu.save_number].name
        audio.stop("menu", 1)
        Transition:fade_in(0.75, function()
            roomy:enter(require "source.game", menu.save_number)
        end)
        fade_music()
    end
}
local levels = {
    text = love.graphics.newText(menu_font, "levels"),
    action = function()
        roomy:enter(require "source.level_selection", menu.save_number)
    end
}
local options = {
    text = love.graphics.newText(menu_font, "options"),
    action = function()
        menu:select(1)
        menu.actions = menu.options
    end
}
local exit = {
    text = love.graphics.newText(menu_font, "exit"),
    action = function()
        Transition.text = ""
        audio.stop("menu", 1)
        Transition:fade_in(0.75, function()
            love.event.quit()
        end)
    end
}

local stored_size = { width = love.graphics.getWidth(), height = love.graphics.getHeight() }
pretty.print(stored_size)
local full_screen = {
    text = love.graphics.newText(menu_font, "fullscreen"),
    action = function()
        local _, _, flags = love.window.getMode()
        local desktop_width, desktop_height = love.window.getDesktopDimensions(flags.display)

        local width = flags.fullscreen and stored_size.width or desktop_width
        local height = flags.fullscreen and stored_size.height or desktop_height
        print(width, height, not flags.fullscreen)
        love.window.setMode(width, height, {fullscreen = not flags.fullscreen})
    end
}

local mute = {
   text = love.graphics.newText(menu_font, "mute"),
   action = function()
      audio.mute()
   end
}
menu.main = { new, levels, options, exit }
menu.options = { full_screen, mute }
menu.actions = menu.main

function menu:enter()
    audio.play("menu", { fadeDuration = 1 })
    local save = love.filesystem.read("save.txt")
    if save then
        menu.save_number = tonumber(save)
        if #self.main < 5 then
            table.insert(self.main, 1, continue)
        end
    end
    audio.play("menu")
end

function menu:draw()
    love.graphics.setCanvas(canvas)
        love.graphics.clear()
        love.graphics.push()
        love.graphics.scale(0.5, 0.5)
        self:draw_circle()
        love.graphics.pop()
    love.graphics.setBlendMode("replace")
    Glow.draw(canvas)

    Transition:draw()
        love.graphics.setBlendMode("alpha")
        love.graphics.push()
        self:draw_circle()
        love.graphics.pop()
        self:draw_menu()
        love.graphics.setBlendMode("lighten", "premultiplied")
        love.graphics.draw(canvas, 0, 0, 0, 2, 2)
    love.graphics.setShader()
    love.graphics.setBlendMode("alpha")
end

function menu:draw_menu()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(title, (love.graphics.getWidth() * 1/3) - title:getWidth(), love.graphics.getHeight() * 1/4)

    love.graphics.setColor(1,1,1)
    local ww, wh = love.graphics.getDimensions()
    local x, y = ww * 2/3, wh * 1/2
    local radius = ww / 5

    for i, action in ipairs(self.actions) do
        love.graphics.push()
        love.graphics.translate(x, y)
        love.graphics.rotate(((i-1) * -math.pi/8) + self.angle)
        love.graphics.translate(-x, -y)

        local twidth = action.text:getWidth()
        if i ~= self.selected then
            love.graphics.setColor(1, 1, 1, 0.5)
        else
            love.graphics.setColor(1, 1, 1, 1)
        end
        local offset = action == exit and 0 or 30
        love.graphics.draw(action.text, x - radius - twidth + offset, y - action.text:getHeight() / 2)
        love.graphics.pop()
    end
end

function menu:draw_circle()
    love.graphics.setLineWidth(30)
    local ww, wh = love.graphics.getDimensions()
    love.graphics.setColor(self.color * 227/255, self.color * 52/255, 0)

    local radius = ww / 5
    local x, y = ww * 2/3, wh * 1/2
    love.graphics.circle('line', x, y, radius)
end

function menu:update(dt)
    flux.update(dt)
    audio.update(dt)
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
        action.action()
    elseif self.actions == self.options and key == "escape" then
        self.actions = menu.main
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
