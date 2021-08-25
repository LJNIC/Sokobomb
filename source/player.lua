local Base = require "source.base"
local flux = require "source.lib.flux"
local Player = Base:extend()
local Pulse = require "source.pulse"

function Player:new(x, y)
    Player.super.new(self, x, y)
    self.offset = Vec2(4, 4)
    self.width = 24
    self.moving = false
    self.pulse = Pulse({0, 1, 1})
end

function Player:draw()
    local drawn_position = self.drawn_position

    love.graphics.setShader(self.pulse.shader)
    self.pulse:update(drawn_position.x, drawn_position.y, self.width, self.width)

    love.graphics.setLineWidth(4)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", drawn_position.x + self.offset.x, drawn_position.y + self.offset.y, self.width, self.width)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", drawn_position.x + self.offset.x, drawn_position.y + self.offset.y, self.width, self.width)
    love.graphics.setColor(0, 163/255, 204/255)
    love.graphics.setLineWidth(3)

    local x_mid = drawn_position.x + TILE_WIDTH/2
    local y_mid = drawn_position.y + TILE_WIDTH/2
    local diamond_offset = 2
    local vertices = {
        x_mid, drawn_position.y + TILE_WIDTH/4 + diamond_offset,
        drawn_position.x + 3/4 * TILE_WIDTH - diamond_offset, y_mid,
        x_mid, drawn_position.y + 3/4 * TILE_WIDTH - diamond_offset,
        drawn_position.x + TILE_WIDTH/4 + diamond_offset, y_mid
    }
    love.graphics.polygon("line", vertices)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setShader()
end

function Player:copy()
    return Player(self.position.x, self.position.y)
end

return Player
