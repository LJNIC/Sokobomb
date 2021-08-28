local flux = require "source.lib.flux"

local Transition = {
    pct = 0,
    shader = love.graphics.newShader("shaders/transition.glsl"),
    flag = false,
    tex = love.graphics.newImage("assets/transition/swipe_right.png"),
    text = "",
}

Transition.shader:send("tex", Transition.tex)

local font = love.graphics.newFont("assets/RobotoCondensed-Regular.ttf", 48)
local col_black = {0, 0, 0, 1}
local col_white = {1, 1, 1, 1}

function Transition:fade_in(duration, fn, delay)
    self.flag = true
    self.pct = 0

    flux.to(self, duration or 1.25, {
        pct = 1
    }):onupdate(function()
        self.shader:send("pct", self.pct)
    end):oncomplete(function()
        fn()
        self:fade_out(duration)
    end):delay(delay or 0)
end

function Transition:fade_out(duration)
    self.flag = true

    flux.to(self, duration or 1.25, {
        pct = 0
    }):onupdate(function()
        self.shader:send("pct", self.pct)
    end):oncomplete(function()
        self.flag = false
    end)
end

function Transition:draw()
    if self.flag then
        love.graphics.setShader(self.shader)

        Transition.shader:send("o_color", col_black)
        Transition.shader:send("f_color", col_white)

        local w, h = love.graphics.getDimensions()
        local x = w * 0.5
        local y = h * 0.5
        local ox = font:getWidth(self.text) * 0.5
        local oy = font:getHeight("") * 0.5
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(font)
        love.graphics.print(self.text, x, y, 0, 1, 1, ox, oy)
        love.graphics.setColor(1, 1, 1, 1)

        Transition.shader:send("o_color", col_white)
        Transition.shader:send("f_color", col_black)
    end
end

return Transition
