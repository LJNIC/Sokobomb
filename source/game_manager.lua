local Box = require "source.box"
local Bomb = require "source.bomb"
local utilities = require "source.utilities"
local Level = require "source.level"
local Transition = require "source.transition"
local Glow = require "source.glow"

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

    local w = self.level.width * 1.5 * TILE_WIDTH
    local h = self.level.height * 1.5 * TILE_WIDTH
    Glow.bloom.glow.size = {w, h}
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

    local new_position = object.position + direction

    local object_at_position = functional.any(self.level.objects, function(o) return o.position == new_position end)

    if self.level:tile_is_walkable(new_position) and not object_at_position then
        object:move(new_position)
        return true
    end

    return false
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

    if not level:tile_is_walkable(new_position) then
        return
    end

    -- Save the current level's state
    level:save()

    -- Check if an object exists at the position and try to move it
    local object_at_position = functional.find_match(level.objects, function(o) return o.alive and o.position == new_position end)
    local moved = not object_at_position and true or self:try_move_object(object_at_position, direction)

    if not moved then
        return
    end

    local bombs = functional.filter(level.objects, function(o) return o:is(Bomb) end)

    -- Tick and explode bombs separately because of bombs exploding bombs
    for _, bomb in ipairs(bombs) do
        bomb:tick(level.objects)
    end

    for _, bomb in ipairs(bombs) do
        if bomb.timer == 0 then
            bomb:explode(level.objects)
        end
    end

    level.player:move(new_position)

    -- We know changes to the level state were made, so we push the saved level state onto the stack
    level:push()

    if self:has_won() then
        self:go_to_next_level()
    end
end

return GameManager
