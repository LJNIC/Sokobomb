local batteries = require("source.lib.batteries"):export()
roomy = require("source.lib.roomy").new()
Vec2 = require("source.lib.vec2")
TILE_WIDTH = 32
TILE_WIDTH_H = TILE_WIDTH * 0.5
DEBUG = false

function love.load()
    roomy:hook()
    if not DEBUG then
        roomy:enter(require "source.menu")
    else
        roomy:enter(require "source.game", 1)
    end
end
