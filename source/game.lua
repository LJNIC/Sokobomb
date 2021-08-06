local Player = require "source.player"
local Bomb = require "source.bomb"
local game = {}

local directions = {down = Vec2(0, 1), left = Vec2(-1, 0), right = Vec2(1, 0), up = Vec2(0, -1)}
local player = Player()
local bombs = {Bomb(4, 4, 7)}

function game:update(dt)
    player:update(dt)
end

function game:draw()
    player:draw()
    for _, bomb in ipairs(bombs) do
        bomb:draw()
    end
end

function game:keypressed(key)
    if directions[key] then
        local direction = directions[key]
        player.position = player.position + direction 

        for i = #bombs, 1, -1 do
            local bomb = bombs[i]
            bomb:tick()
            if player.position == bomb.position then
                bomb.position = bomb.position + direction
            end
            if bomb.timer == 0 then
                table.remove(bombs, i)
            end
        end
    elseif key == "r" then
        love.event.quit("restart")
    elseif key == "escape" then
        love.event.quit()
    end
end

return game
