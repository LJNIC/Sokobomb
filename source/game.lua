local Player = require "source.player"
local Bomb = require "source.bomb"
local game = {}

local directions = {down = Vec2(0, 1), left = Vec2(-1, 0), right = Vec2(1, 0), up = Vec2(0, -1)}
local player = Player()
local bomb = Bomb(4, 4, 7)

function game:draw()
    player:draw()
    if bomb then bomb:draw() end
end

function game:keypressed(key)
    if directions[key] then
        player.position = player.position + directions[key]
        if bomb then
            bomb:tick()
            if bomb.timer == 0 then
                bomb = nil
            end
        end
    end
end

return game
