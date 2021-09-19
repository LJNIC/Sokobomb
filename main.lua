local batteries = require("source.lib.batteries"):export()
roomy = require("source.lib.roomy").new()
Vec2 = require("source.lib.vec2")
TILE_WIDTH = 32
DEBUG = false

function love.load()
    roomy:hook()
    roomy:enter(require "source.menu")
end
