local Player = require "source.player"
local Bomb = require "source.bomb"
local Box = require "source.box"
local Level = require "source.level"
local flux = require "source.lib.flux"
local game = {}

local directions = {down = Vec2(0, 1), left = Vec2(-1, 0), right = Vec2(1, 0), up = Vec2(0, -1)}

local player = Player(1, 1)
local objects = {Box(5, 7), Box(6, 7), Bomb(4, 4, 9)}
local level = Level()

local function move_object(object, direction)
    local new_position = object.position + direction
    if level:tile_at(new_position) == 1 or functional.any(objects, function(object) return object.position == new_position end) then
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
    local x = width / 2 - (level.width / 2) * tile_width - tile_width - 4
    local y = height / 2 - (level.height / 2) * tile_width - tile_width - 4

    love.graphics.translate(x, y)

    level:each_tile(
        function(x, y, tile) 
            if tile == 1 then
                love.graphics.ellipse("line", x * tile_width + 16, y * tile_width + 16, 7, 7)
            end
        end
    )

    player:draw()

    for _, object in ipairs(objects) do
        if object.alive then
            object:draw()
        end
    end

    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", tile_width - 2, tile_width - 2, tile_width * level.width + 4, tile_width * level.height + 4)
end

local function turn(direction)
    if player.moving then
        return
    end

    local new_position = player.position + direction

    if new_position.x < 1 or new_position.x > level.width or new_position.y < 1 or new_position.y > level.height then
        return
    end

    if level:tile_at(new_position) == 1 then
        return
    end

    local moved = true
    for _, object in ipairs(objects) do
        object:tick()
        if object.alive and object.position == new_position then
            moved = move_object(object, direction)
            break
        end
    end

    if moved then
        player:move(new_position)
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
