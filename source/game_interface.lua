local arrow_width = 32

local function draw_arrow()
    love.graphics.line(0 + 8,arrow_width/2, arrow_width - 8,arrow_width/2)
    love.graphics.line(arrow_width/2,0 + 8, 8,arrow_width/2, arrow_width/2,arrow_width - 8)
end

local function draw_arrows()
    local arrows_pos = Vec2(love.graphics.getWidth()/2 - 45, love.graphics.getHeight() * 3/4)
    local arrows = {
        up = Vec2(arrows_pos.x + ((arrow_width * 3/2) - arrow_width/2), arrows_pos.y - 10),
        down = Vec2(arrows_pos.x + ((arrow_width  * 3/2) - arrow_width/2), arrows_pos.y + arrow_width),
        left = Vec2(arrows_pos.x - 10, arrows_pos.y + arrow_width),
        right = Vec2(arrows_pos.x + (arrow_width * 2) + 10, arrows_pos.y + arrow_width)
    }

    for direction, arrow in pairs(arrows) do
        love.graphics.rectangle("line", arrow.x, arrow.y, arrow_width, arrow_width)

        local angle = 0
        if direction == "right" then
            angle = math.pi
        elseif direction == "up" then
            angle = math.pi/2
        elseif direction == "down" then
            angle = -math.pi/2
        end
        love.graphics.push()
            love.graphics.translate(arrow.x + arrow_width/2, arrow.y + arrow_width/2)
            love.graphics.rotate(angle)
            love.graphics.translate(-arrow_width/2, -arrow_width/2)
            draw_arrow()
        love.graphics.pop()
    end
end

return function(level_number, turn_count)
    love.graphics.setLineWidth(2)
    if level_number == 1 then
        draw_arrows()
    end
end
