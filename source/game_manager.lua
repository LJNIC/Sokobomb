local Box = require "source.box"
local Bomb = require "source.bomb"
local utilities = require "source.utilities"
local Level = require "source.level"
local Transition = require "source.transition"

local GameManager = {
    level = nil,
    level_number = 1,
    levels = {}
}

local levels = require "levels"
local max_level = #levels

for _,level in ipairs(levels) do
    table.insert(GameManager.levels, Level("levels/" .. level))
end

function GameManager:reload()
    self.level:reset()
end

function GameManager:enter(level_number)
    print(level_number)
    self.level_number = level_number
    self.level = self.levels[level_number]
    self.level.player:transition_in()

    local w = self.level.width * 1.5 * TILE_WIDTH
    local h = self.level.height * 1.5 * TILE_WIDTH
end

function GameManager:go_to_next_level(duration, level_number)
    local next_level = level_number or self.level_number + 1
    love.filesystem.write("save.txt", tostring(self.level_number + 1))

    self.level.player:transition_out()
    if next_level > max_level then
        love.filesystem.remove("save.txt")
        Transition.text = ""
        Transition:fade_in(duration, function() 
            roomy:enter(require "source.done") 
        end, 1.5)
    else
        Transition.text = self.levels[next_level].name
        Transition:fade_in(duration, function()
            self:enter(next_level)
        end, 1.5)
    end
end

-- Tries to move an object, returning whether the object was moved or not
function GameManager:try_move_object(object, direction)
    if not object.movable then
        return false
    end

    local new_position = object.position + direction

    local object_at_position = functional.any(self.level.objects, function(o) return o.alive and o.position == new_position end)

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
    if not level.player.alive then return end

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

    level.player:move(new_position)

    local bombs = functional.filter(level.objects, function(o) return o:is(Bomb) end)

    -- Tick and explode bombs separately because of bombs exploding bombs
    for _, bomb in ipairs(bombs) do
        bomb:tick(level.objects)
    end

    for _, bomb in ipairs(bombs) do
        if bomb.alive and bomb.timer == 0 then
            bomb:explode(level.objects, level.player)
        end
    end


    -- We know changes to the level state were made, so we push the saved level state onto the stack
    level:push()

    if self:has_won() then
        self:go_to_next_level()
    end
end

return GameManager
