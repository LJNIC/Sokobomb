local Base = require "source.base"
local Themes = require "source.themes"
local flux = require "source.lib.flux"
local Player = Base:extend()

function Player:new(x, y)
    Player.super.new(self, x, y)
    self.offset = Vec2(4, 4)
    self.width = TILE_WIDTH - 8
    self.moving = false
    self.percent = 1
    self.angle = math.pi/4
end

function Player:move(new_position)
    Player.super.move(self, new_position)
    self.angle = math.pi/4
    flux.to(self, 0.5, {angle = math.pi + math.pi/4})
end

function Player:fake_move(direction)
    local new_drawn_position = self.position * TILE_WIDTH + (direction * 5)
    flux.to(self.drawn_position, 0.15, {x = new_drawn_position.x, y = new_drawn_position.y}):oncomplete(function()
        flux.to(self.drawn_position, 0.15, {x = self.position.x * TILE_WIDTH, y = self.position.y * TILE_WIDTH})
    end)
end

function Player:transition_in()
    self.percent = 0
    flux.to(self, 1.5, {percent = 1}):delay(1)
end

function Player:transition_out()
    self.percent = 1
    flux.to(self, 1.5, {percent = 0}):delay(0.5)
end

function Player:drawRotatedRectangle()
    local x = self.drawn_position.x + TILE_WIDTH/2
    local y = self.drawn_position.y + TILE_WIDTH/2
    local width = self.percent * TILE_WIDTH/4
    if self.percent < 1 then
        self.angle = self.percent * (math.pi*2 + math.pi/4)
    end

	love.graphics.push("all")
    Themes.set_color("player_diamond")
    love.graphics.setLineWidth(3 * self.percent)
	love.graphics.translate(x, y)
	love.graphics.rotate(self.angle)
    love.graphics.translate(-width/2, -width/2)
	love.graphics.rectangle("line", 0, 0, width, width)
	love.graphics.pop()
end

function Player:draw_transition()
    local drawn = self.drawn_position + self.offset

    love.graphics.setLineWidth(4)
    Themes.set_color("player_outer")

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

    self:drawRotatedRectangle()
end

function Player:draw()
    local drawn_position = self.drawn_position

    if self.percent < 1 then
        self:draw_transition()
        return
    end

    love.graphics.setLineWidth(4)
    Themes.set_color("player_inner")
    love.graphics.rectangle("fill", drawn_position.x + self.offset.x, drawn_position.y + self.offset.y, self.width, self.width)

    Themes.set_color("player_outer")
    love.graphics.rectangle("line", drawn_position.x + self.offset.x, drawn_position.y + self.offset.y, self.width, self.width)

    self:drawRotatedRectangle()
end

function Player:copy()
    local p = Player(self.position.x, self.position.y)
    p.alive = self.alive
    return p
end

return Player
