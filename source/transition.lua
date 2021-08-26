local flux = require "source.lib.flux"

local Transition = {
    pct = 0,
    shader = love.graphics.newShader("shaders/transition.glsl"),
    flag = false,
    tex = love.graphics.newImage("assets/transition/swipe_right.png"),
}

Transition.shader:send("tex", Transition.tex)
Transition.shader:send("f_color", {0, 0, 0, 1})

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

return Transition
