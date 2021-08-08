local Box = require "source.box"
local Bomb = require "source.bomb"
local Player = require "source.player"
local Breakable = require "source.breakable"
local Object = require "source.lib.classic"

local Level = Object:extend()

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
        elseif object.data.is_breakable then
            table.insert(self.objects, Breakable(x, y))
        elseif object.data.is_player then
            self.player = Player(x, y)
        end
    end
    table.insert(self.objects, Bomb(3, 7, 5))
end

function Level:tile_at(position_or_x, y)
    local x = y == nil and position_or_x.x or position_or_x
    local y = y == nil and position_or_x.y or y

    return self.tiles[y] and self.tiles[y][x] or 1
end

function Level:each_tile(f)
    for y = 1, self.height do
        for x = 1, self.width do
            f(x, y, self:tile_at(x, y))
        end
    end
end

return Level
