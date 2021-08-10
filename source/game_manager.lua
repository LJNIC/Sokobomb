local utilities = require "source.utilities"
local Level = require "source.level"
local Transition = require "source.transition"

local GameManager = {
    level = nil,
    level_number = 0,
}

local max_level = #(love.filesystem.getDirectoryItems("levels"))

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

local function tile_draw(x, y, tile)
    if tile == 1 then
        love.graphics.ellipse("line", x * tile_width + 16, y * tile_width + 16, 7, 7, 100)
    end
end

function GameManager:draw()
    local width, height = love.graphics.getDimensions()
    local x = width / 2 - (self.level.width / 2) * tile_width - tile_width - 4
    local y = height / 2 - (self.level.height / 2) * tile_width - tile_width - 4

    love.graphics.push()
    love.graphics.translate(x, y)
    self.level:each_tile(tile_draw)
    self.level.player:draw()

    for _, object in ipairs(self.level.objects) do
        if object.alive then
            object:draw()
        end
    end

    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", tile_width - 2, tile_width - 2,
        tile_width * self.level.width + 4, tile_width * self.level.height + 4)
    love.graphics.pop()
end

-- Tries to move an object, returning whether the object was moved or not
function GameManager:try_move_object(object, direction)
    if not object.movable then
        return false
    end

    local new_position = object.position + direction
    if self.level:tile_at(new_position) == 1 or functional.any(self.level.objects, function(object) return object.position == new_position end) then
        return false
    end

    object:move(new_position)
    return true
end

function GameManager:turn(direction)
    if self.level.player.moving then
        return
    end

    local new_position = self.level.player.position + direction

    if new_position.x < 1 or new_position.x > self.level.width or new_position.y < 1 or new_position.y > self.level.height then
        return
    end

    if self.level:tile_at(new_position) == 1 then
        return
    end

    -- Save the current level's state
    self.level:save()
    local moved = true
    for _, object in ipairs(self.level.objects) do
        if object.alive and object.position == new_position then
            moved = self:try_move_object(object, direction)
        end
    end

    if not moved then
        return
    end

    for _, object in ipairs(self.level.objects) do
        object:tick(self.level.objects)
    end

    self.level.player:move(new_position)
    -- If a turn was done, we push the saved level state onto the stack
    self.level:push()
end

function GameManager:keypressed(key)
    if utilities.directions[key] then
        self:turn(utilities.directions[key])
    elseif key == "z" then
        self.level:undo()
    end
end

return GameManager
