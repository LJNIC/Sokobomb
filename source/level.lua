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
        elseif object.data.is_infinite then
            table.insert(self.objects, Bomb(x, y, 1, true))
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

function Level:check_neighbor(x, y, dx, dy, recurse)
    local di = (y - 1 + dy) * self.width + (x + dx)
    local target = self.tiles[di]

    local is_single = true
    local n_walls = {}
    if recurse and target == 1 then
        local nx = x + dx
        local ny = y + dy
        local north = self:check_neighbor(nx, ny, 0, -1)
        local south = self:check_neighbor(nx, ny, 0, 1)
        local west = self:check_neighbor(nx, ny, -1, 0)
        local east = self:check_neighbor(nx, ny, 1, 0)

        if north ~= 1 and south ~= 1 and west ~= 1 and east ~= 1 then
            --meaning only a single wall tile
            is_single = false
        else
            n_walls.north = north
            n_walls.south = south
            n_walls.west = west
            n_walls.east = east
        end
    end

    return target, n_walls, is_single
end

function Level:draw_wall(x, y)
    love.graphics.setLineWidth(2)
    love.graphics.setLineStyle("rough")
    love.graphics.setColor(1, 1, 1)
    local north, nnw, nis = self:check_neighbor(x, y, 0, -1, true)
    local south, snw, sis = self:check_neighbor(x, y, 0, 1, true)
    local west, wnw, wis = self:check_neighbor(x, y, -1, 0, true)
    local east, enw, eis = self:check_neighbor(x, y, 1, 0, true)

    local gap = 4
    local lx = x * TILE_WIDTH
    local ly = y * TILE_WIDTH

    if north == 1 then
        local hgap = nis and 0 or gap
        local nx = lx + hgap
        local ny = ly - gap
        local nw = lx + TILE_WIDTH
        local nh = ly - gap
        if nnw.west ~= 1 then
            nx = lx + gap
        end
        if nnw.east ~= 1 then
            nw = nw - gap
        end
        love.graphics.line(nx, ny, nw, nh)
    end

    if south == 1 then
        local hgap = sis and 0 or gap
        local sx = lx - hgap
        local sy = ly + TILE_WIDTH + gap
        local sw = lx + TILE_WIDTH
        local sh = ly + TILE_WIDTH + gap
        if snw.west ~= 1 then
            sx = lx + gap
        end
        if snw.east ~= 1 then
            sw = sw - gap
        end
        love.graphics.line(sx, sy, sw, sh)
    end

    if west == 1 then
        local vgap = wis and 0 or gap
        local wx = lx - gap
        local wy = ly - vgap
        local ww = lx - gap
        local wh = ly + TILE_WIDTH
        if wnw.north ~= 1 then
            wy = ly + gap
        end
        if wnw.south ~= 1 then
            wh = wh - gap
        end
        love.graphics.line(wx, wy, ww, wh)
    end

    if east == 1 then
        local vgap = eis and 0 or gap
        local ex = lx + TILE_WIDTH + gap
        local ey = ly + vgap
        local ew = lx + TILE_WIDTH + gap
        local eh = ly + TILE_WIDTH
        if enw.north ~= 1 then
            ey = ly + gap
        end
        if enw.south ~= 1 then
            eh = eh - gap
        end
        love.graphics.line(ex, ey, ew, eh)
    end

    --first lg.line is the first expression (i.e, north and then west)
    if north == 1 and west == 1 then
        love.graphics.line(
            lx + TILE_WIDTH - gap, ly - gap,
            lx - gap, ly - gap, 
            lx - gap, ly + TILE_WIDTH - gap
        )
    end

    if north == 1 and east == 1 then
        love.graphics.line(
            lx + gap, ly - gap, 
            lx + TILE_WIDTH + gap, ly - gap,
            lx + TILE_WIDTH + gap, ly + TILE_WIDTH - gap
        )
    end

    if south == 1 and west == 1 then
        love.graphics.line(
            lx - gap, ly + gap,
            lx - gap, ly + TILE_WIDTH + gap, 
            lx + TILE_WIDTH - gap, ly + TILE_WIDTH + gap
        )
    end

    if south == 1 and east == 1 then
        love.graphics.line(
            lx + gap, ly + TILE_WIDTH + gap, 
            lx + TILE_WIDTH + gap, ly + TILE_WIDTH + gap,
            lx + TILE_WIDTH + gap, ly + gap
        )
    end

    love.graphics.setLineStyle("rough")
end

function Level:draw_tile(x, y, tile)
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.setLineWidth(4)

    if tile == "goal" then
        local cornerX, cornerY = x * TILE_WIDTH + Box.offset.x, y * TILE_WIDTH + Box.offset.y
        love.graphics.line(cornerX, cornerY, cornerX + Box.width, cornerY + Box.width)
        love.graphics.line(cornerX + Box.width, cornerY, cornerX, cornerY + Box.width)
        love.graphics.rectangle("line", cornerX, cornerY, Box.width, Box.width)
    end

    if tile ~= "wall" then
        self:draw_wall(x, y)
    end

    love.graphics.setColor(1, 1, 1)
end

function Level:draw_tiles()
    for y = 1, self.height do
        for x = 1, self.width do
            self:draw_tile(x, y, self:tile_at(x, y))

            if DEBUG then
                love.graphics.setLineWidth(1)
                love.graphics.setColor(1, 0, 0, 0.5)
                love.graphics.rectangle("line", x * TILE_WIDTH, y * TILE_WIDTH, TILE_WIDTH, TILE_WIDTH)
                love.graphics.setColor(1, 0, 0, 1)
                love.graphics.print(self.tiles[i], x * TILE_WIDTH, y * TILE_WIDTH)
            end
        end
    end
end

function Level:draw_objects()
    self.player:draw()

    for _, object in ipairs(self.objects) do
        if object.alive then
            object:draw()
        end
    end
end

function Level:tile_is_walkable(base_position_x, y)
    local tile = self:tile_at(base_position_x, y)
    return tile and tile ~= "wall"
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

    if x < 1 or x > self.width or y < 1 or y > self.height then
        return nil
    end

    return tile_types[self.tiles[(y - 1) * self.width + x]]
end

return Level
