local Glow = {
    amount = 3,
}

local w, h = love.graphics.getDimensions()
local glowy_bits = love.graphics.newCanvas(w * 0.5, h * 0.5)
local glow_shader = love.graphics.newShader("shaders/glow_h.glsl")
local glow_shader_other = love.graphics.newShader("shaders/glow_v.glsl")

function Glow.draw(canvas)
    for i = 1, Glow.amount do
        love.graphics.setShader(glow_shader)
        love.graphics.setCanvas(glowy_bits)
        love.graphics.draw(canvas)
        love.graphics.setShader(glow_shader_other)
        love.graphics.setCanvas(canvas)
        love.graphics.draw(glowy_bits)
    end
    love.graphics.setShader()
    love.graphics.setCanvas()
end

return Glow
