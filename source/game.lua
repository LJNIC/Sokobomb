local game = {}

local directions = {down = vec2(0, 1), left = vec2(-1, 0), right = vec2(1, 0), up = vec2(0, -1)}
local player = {position = vec2(1, 1)}

function game:draw()
    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line", 32 * player.position.x, 32 * player.position.y, 32, 32)
end

function game:keypressed(key)
  if directions[key] then
    player.position = (player.position + directions[key])
  end
end

return game
