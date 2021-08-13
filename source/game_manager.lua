local Box = require "source.box"
local utilities = require "source.utilities"
local Level = require "source.level"
local Transition = require "source.transition"

local GameManager = {
    level = nil,
    level_number = 1,
}

local max_level = #(love.filesystem.getDirectoryItems("levels"))

function GameManager:reload()
    self:enter(self.level_number)
end

function GameManager:enter(level_number)
    level_number = math.wrap(level_number, 1, max_level + 1)
    self.level_number = level_number
    self.level = Level("levels/level" .. level_number)
end

function GameManager:go_to_next_level(duration)
    Transition:fade_in(duration, function()
        self:enter(self.level_number + 1)
    end)
end

-- Tries to move an object, returning whether the object was moved or not
function GameManager:try_move_object(object, direction)
    if not object.movable then
        return false
    end

    local level = self.level
    local new_position = object.position + direction

    if new_position.x < 1 or new_position.x > level.width or new_position.y < 1 or new_position.y > level.height then
        return false
    end

    local object_at_position = functional.any(level.objects, function(object) return object.position == new_position end)
    if not level:tile_is_walkable(new_position) or object_at_position then
        return false
    end

    object:move(new_position)
    return true
end

function GameManager:has_won() 
    local alive_boxes = functional.filter(self.level.objects, function(o) return o:is(Box) and o.alive end)
    return functional.all(alive_boxes, function(box) return self.level:tile_at(box) == "goal" end)
end

function GameManager:turn(direction)
    local level = self.level

    if level.player.moving then
        return
    end

    local new_position = level.player.position + direction

    if new_position.x < 1 or new_position.x > level.width or new_position.y < 1 or new_position.y > level.height then
        return
    end

    if not level:tile_is_walkable(new_position) then
        return
    end

    -- Save the current level's state
    level:save()
    local moved = true
    for _, object in ipairs(level.objects) do
        if object.alive and object.position == new_position then
            moved = self:try_move_object(object, direction)
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

    if self:has_won() then
        self:go_to_next_level()
    end
end

return GameManager
