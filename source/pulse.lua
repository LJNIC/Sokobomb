local Flux = require("source.lib.flux")

local Pulse = class({
    name = "Pulse"
})

Pulse.tx = 0
Pulse.ty = 0
Pulse.def_min = 0.5
Pulse.def_max = 1
Pulse.def_dur = 0.5

function Pulse:new(color, min_value, max_value, duration)
    self.color = color
    self.min_value = min_value or Pulse.def_min
    self.max_value = max_value or Pulse.def_max
    self.duration = duration or Pulse.def_dur
    self.pct = self.max_value

    self.shader = love.graphics.newShader("shaders/pulse.glsl")
    self.shader:send("pct", self.pct)
    self.shader:send("pulse_color", self.color)

    self:do_pulse(self.min_value)
end

function Pulse:do_pulse(to_value)
    Flux.to(self, self.duration, {
        pct = to_value,
    }):onupdate(function()
        self.shader:send("pct", self.pct)
    end):oncomplete(function()
        if to_value == self.min_value then
            self:do_pulse(self.max_value)
        else
            self:do_pulse(self.min_value)
        end
    end)
end

function Pulse:update(x, y, w, h)
    self.shader:send("translate", {Pulse.tx, Pulse.ty})
    self.shader:send("pos", {x, y})
    self.shader:send("size", {w, h})
end

return Pulse
