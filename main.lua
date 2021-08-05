local batteries = require("source.lib.batteries"):export()
vec2 = require("source.lib.vec2")
local roomy = require("source.lib.roomy").new()

function love.load()
    roomy:hook()
    roomy:enter(require("source.game"))
end
