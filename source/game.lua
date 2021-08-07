local Player = require "source.player"
local Bomb = require "source.bomb"
local flux = require "source.lib.flux"
local game = {}

local directions = {down = Vec2(0, 1), left = Vec2(-1, 0), right = Vec2(1, 0), up = Vec2(0, -1)}
local player = Player()
local bombs = {Bomb(4, 4, 9)}
local tiles = functional.generate(15, function(x) return functional.generate(15, function(y) return 0 end) end)
tiles[3][3] = 1
tiles[7][3] = 1
tiles[3][7] = 1
tiles[9][6] = 1

function game:update(dt)
    flux.update(dt)
end

function game:draw()
    for x = 1, 15 do
        for y = 1, 15 do
            if tiles[x][y] == 1 then
                love.graphics.ellipse("line", x * tile_width + 16, y * tile_width + 16, 5, 5)
            end
        end
    end
    player:draw()
    for _, bomb in ipairs(bombs) do
        bomb:draw()
    end
end

local function turn(direction)
    if player.moving then
        return
    end

    local new_position = player.position + direction

    if tiles[new_position.x][new_position.y] == 1 then
        return
    end

    player:move(new_position)

    for i = #bombs, 1, -1 do
        local bomb = bombs[i]
        bomb:tick()
        if player.position == bomb.position then
            bomb:move(bomb.position + direction)
        end
        if bomb.timer == 0 then
            table.remove(bombs, i)
        end
    end
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
