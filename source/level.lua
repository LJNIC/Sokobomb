local Box = require "source.box"
local Bomb = require "source.bomb"
local Player = require "source.player"
local Breakable = require "source.breakable"
local Object = require "source.lib.classic"

local Level = Object:extend()
Level.tile_types = { [0] = "floor", [1] = "wall", [2] = "goal", [3] = "border" }
local tile_types = Level.tile_types

function Level:new(file_name)
    local data = require(file_name)
    self.width = data.metadata.cols
    self.height = data.metadata.rows

    self.tiles = data.tiles

    self.objects = {}
    for _, object in ipairs(data.objects) do
        local x, y = object.x, object.y
        if object.data.is_box then
            table.insert(self.objects, Box(x, y))
        elseif object.data.is_bomb then
            table.insert(self.objects, Bomb(x, y, object.data.timer))
        elseif object.data.is_d_wall then
            table.insert(self.objects, Breakable(x, y))
        elseif object.data.is_player then
            self.player = Player(x, y)
        end
    end

    self.stack = {{ player = self.player, objects = self.objects }}
end

function Level:save()
    self.saved_state = { player = self.player:copy(), objects = table.copy(self.objects, true) }
end

function Level:push()
    table.insert(self.stack, self.saved_state)
end

function Level:undo()
    if #self.stack > 1 then
        local top = table.remove(self.stack)

        self.player:move(top.player.position)
        for i, object in ipairs(self.objects) do
            object:undo(top.objects[i])
        end
    end
end

function Level:check_neighbor(x, y, dx, dy)
    local di = (y - 1 + dy) * self.width + (x + dx)
    local target = self.tiles[di]
    return target
end

function Level:draw_wall(x, y)
    love.graphics.setLineWidth(4)
    local north = self:check_neighbor(x, y, 0, -1)
    local south = self:check_neighbor(x, y, 0, 1)
    local west = self:check_neighbor(x, y, -1, 0)
    local east = self:check_neighbor(x, y, 1, 0)

    if north == 1 then
        love.graphics.rectangle("fill", x * tile_width, y * tile_width, tile_width, 1)
    end

    if south == 1 then
        love.graphics.rectangle("fill", x * tile_width, y * tile_width + tile_width, tile_width, 1)
    end

    if west == 1 then
        love.graphics.rectangle("fill", x * tile_width, y * tile_width, 1, tile_width)
    end

    if east == 1 then
        love.graphics.rectangle("fill", x * tile_width + tile_width, y * tile_width, 1, tile_width)
    end
end

function Level:draw_tile(x, y, tile)
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.setLineWidth(4)
    if tile == "goal" then
        local cornerX, cornerY = x * tile_width + Box.offset.x, y * tile_width + Box.offset.y
        love.graphics.line(cornerX, cornerY, cornerX + Box.width, cornerY + Box.width)
        love.graphics.line(cornerX + Box.width, cornerY, cornerX, cornerY + Box.width)
        love.graphics.rectangle("line", cornerX, cornerY, Box.width, Box.width)
    end
    love.graphics.setColor(1, 1, 1)
end

function Level:draw()
    for y = 1, self.height do
        for x = 1, self.width do
            self:draw_tile(x, y, self:tile_at(x, y))

            local i = (y - 1) * self.width + x
            if self.tiles[i] ~= 1 then
                self:draw_wall(x, y)
            end
        end
    end

    self.player:draw()

    for _, object in ipairs(self.objects) do
        if object.alive then
            object:draw()
        end
    end
end

function Level:tile_is_walkable(base_position_x, y)
    return self:tile_at(base_position_x, y) ~= "wall"
end

function Level:tile_at(base_position_x, y)
    local x = base_position_x
    local y = y

    if y == nil and base_position_x.position then
        x = base_position_x.position.x
        y = base_position_x.position.y
    elseif y == nil and base_position_x.x then
        x = base_position_x.x
        y = base_position_x.y
    end

    return tile_types[self.tiles[(y - 1) * self.width + x]]
end

function Level:each_tile(f)
end

return Level
