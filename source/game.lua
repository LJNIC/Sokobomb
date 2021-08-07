local Player = require "source.player"
local Bomb = require "source.bomb"
local Box = require "source.box"
local flux = require "source.lib.flux"
local game = {}

local directions = {down = Vec2(0, 1), left = Vec2(-1, 0), right = Vec2(1, 0), up = Vec2(0, -1)}

local player = Player(1, 1)
local bombs = {Bomb(4, 4, 9)}
local boxes = {Box(5, 7)}

local tiles = functional.generate(16, function(x) return functional.generate(16, function(y) return 0 end) end)
tiles[3][3] = 1
tiles[7][3] = 1
tiles[3][7] = 1
tiles[9][6] = 1

local function tile_at(position)
    return tiles[position.x] and tiles[position.x][position.y] or 1
end

local function move_object(object, direction)
    local new_position = object.position + direction
    if tile_at(new_position) == 1 then
        return false
    end
    object:move(new_position)
    return true
end

love.keyboard.setKeyRepeat(true)

function game:update(dt)
    flux.update(dt)
end

function game:draw()
    local width, height = love.graphics.getDimensions()
    local x = width / 2 - (#tiles / 2) * tile_width - tile_width - 4
    local y = height / 2 - (#tiles / 2) * tile_width - tile_width - 4

    love.graphics.translate(x, y)

    for x = 1, 15 do
        for y = 1, 15 do
            if tiles[x][y] == 1 then
                love.graphics.ellipse("line", x * tile_width + 16, y * tile_width + 16, 7, 7)
            end
        end
    end

    player:draw()

    for _, bomb in ipairs(bombs) do
        bomb:draw()
    end

    for _, box in ipairs(boxes) do
        box:draw()
    end

    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", tile_width - 2, tile_width - 2, tile_width * #tiles + 4, tile_width * #tiles + 4)
end

local function turn(direction)
    if player.moving then
        return
    end

    local new_position = player.position + direction

    if new_position.x < 1 or new_position.x > #tiles or new_position.y < 1 or new_position.y > #tiles then
        return
    end

    if tile_at(new_position) == 1 then
        return
    end

    for i = 1, #boxes do
        local box = boxes[i]
        if new_position == box.position then
            if not move_object(box, direction) then
                return
            end
        end
    end

    for i = #bombs, 1, -1 do
        local bomb = bombs[i]
        bomb:tick()
        if new_position == bomb.position then
            if not move_object(bomb, direction) then
                return
            end
        end
        if bomb.timer == 0 then
            table.remove(bombs, i)
        end
    end

    player:move(new_position)
end

function game:keypressed(key)
    if directions[key] then
        turn(directions[key])
    elseif key == "r" then
        love.event.quit("restart")
    elseif key == "escape" then
        love.event.quit()
    end
end

return game
