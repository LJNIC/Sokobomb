local batteries = require("source.lib.batteries"):export()
local roomy = require("source.lib.roomy").new()
Vec2 = require("source.lib.vec2")
TILE_WIDTH = 32
START_LEVEL_NUMBER = 2
DEBUG = true

function love.load()
    roomy:hook()
    roomy:enter(require("source.game"))
end
