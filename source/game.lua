local Player = require "source.player"
local game = {}

local directions = {down = Vec2(0, 1), left = Vec2(-1, 0), right = Vec2(1, 0), up = Vec2(0, -1)}
local player = Player()

function game:draw()
    player:draw()
end

function game:keypressed(key)
  if directions[key] then
    player.position = player.position + directions[key]
  end
end

return game
