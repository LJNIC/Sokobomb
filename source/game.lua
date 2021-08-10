local Player = require "source.player"
local Bomb = require "source.bomb"
local Box = require "source.box"
local Level = require "source.level"
local utilities = require "source.utilities"
local flux = require "source.lib.flux"
local game = {}

local level = Level("levels/level1")
local level_number = 1
local max_level = #(love.filesystem.getDirectoryItems("levels"))

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
                love.graphics.ellipse("line", x * tile_width + 16, y * tile_width + 16, 7, 7, 100)
            end
        end
    )

    level.player:draw()

    for _, object in ipairs(level.objects) do
        if object.alive then
            object:draw()
        end
    end

    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", tile_width - 2, tile_width - 2, tile_width * level.width + 4, tile_width * level.height + 4)
end

-- Tries to move an object, returning whether the object was moved or not
local function try_move_object(object, direction)
    if not object.movable then
        return false
    end

    local new_position = object.position + direction
    if level:tile_at(new_position) == 1 or functional.any(level.objects, function(object) return object.position == new_position end) then
        return false
    end

    object:move(new_position)
    return true
end

local function turn(direction)
    if level.player.moving then
        return
    end

    local new_position = level.player.position + direction

    if new_position.x < 1 or new_position.x > level.width or new_position.y < 1 or new_position.y > level.height then
        return
    end

    if level:tile_at(new_position) == 1 then
        return
    end

    -- Save the current level's state
    level:save()
    local moved = true
    for _, object in ipairs(level.objects) do
        if object.alive and object.position == new_position then
            moved = try_move_object(object, direction)
        end
    end

    if not moved then
        return
    end

    for _, object in ipairs(level.objects) do
        object:tick(level.objects)
    end

    level.player:move(new_position)
    -- If a turn was done, we push the saved level state onto the stack
    level:push()
end

function game:keypressed(key)
    if utilities.directions[key] then
        turn(utilities.directions[key])
    elseif key == "z" then
        level:undo()
    elseif key == "r" then
        love.event.quit("restart")
    elseif key == "n" then
        level_number = math.wrap(level_number + 1, 1, max_level + 1)
        level = Level("levels/level" .. tostring(level_number))
    elseif key == "escape" then
        love.event.quit()
    end
end

return game
