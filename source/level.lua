local Object = require "source.lib.classic"

local Level = Object:extend()

function Level:new()
    self.tiles = functional.generate(16, function(x) return functional.generate(16, function(y) return 0 end) end)
    self.tiles[3][3] = 1
    self.tiles[7][3] = 1
    self.tiles[3][7] = 1
    self.tiles[9][6] = 1

    self.width = 16
    self.height = 16
end

function Level:tile_at(position_or_x, y)
    local x = y == nil and position_or_x.x or position_or_x
    local y = y == nil and position_or_x.y or y

    return self.tiles[x] and self.tiles[x][y] or 1
end

function Level:each_tile(f)
    for x = 1, self.width do
        for y = 1, self.height do
            f(x, y, self:tile_at(x, y))
        end
    end
end

return Level
