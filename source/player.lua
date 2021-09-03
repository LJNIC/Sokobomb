local Base = require "source.base"
local flux = require "source.lib.flux"
local Player = Base:extend()

function Player:new(x, y)
    Player.super.new(self, x, y)
    self.offset = Vec2(4, 4)
    self.width = 24
    self.moving = false
    self.percent = 1
end

function Player:transition_in()
    self.percent = 0
    flux.to(self, 1.5, {percent = 1}):delay(1)
end

function Player:transition_out()
    self.percent = 1
    flux.to(self, 1.5, {percent = 0}):delay(0.5)
end

function Player:draw_transition()
    local drawn = self.drawn_position + self.offset

    love.graphics.setLineWidth(4)
    love.graphics.setColor(1, 1, 1)

    if self.percent > 0 then
        local to = (self.width * math.min(self.percent/0.25, 1))
        love.graphics.rectangle("line", drawn.x, drawn.y, to, 0.01)
    end

    if self.percent > 0.25 then
        local to = (self.width * math.min((self.percent - 0.25)/0.25, 1))
        love.graphics.rectangle("line", drawn.x + self.width, drawn.y, 0.01, to)
    end

    if self.percent > 0.5 then
        local to = (self.width * math.min((self.percent - 0.5)/0.25, 1))
        love.graphics.rectangle("line", drawn.x + self.width, drawn.y + self.width, -to, 0.01)
    end

    if self.percent > 0.75 then
        local to = (self.width * math.min((self.percent - 0.75)/0.25, 1))
        love.graphics.rectangle("line", drawn.x, drawn.y + self.width, 0.01, -to)
    end
end

function Player:draw()
    local drawn_position = self.drawn_position

    if self.percent < 1 then
        self:draw_transition()
        return
    end

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
   -- love.graphics.polygon("line", vertices)

    love.graphics.setColor(1, 1, 1)
end

function Player:copy()
    return Player(self.position.x, self.position.y)
end

return Player
