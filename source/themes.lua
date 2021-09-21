local Themes = {}

local current = "default"
local palettes = {
    default = {
        wall = {48/255, 54/255, 95/255},
        goal = {0.5, 0.5, 0.5},
        player_inner = {0, 0, 0},
        player_outer = {1, 1, 1},
        player_diamond = {0, 163/255, 204/255},
        explosion_inner = {0, 0, 0},
        breakable = {242/255, 206/255, 0},
        bomb_pulse_outer = {0.5, 0.5, 0.5},
        bomb_pulse_inner = {227/255, 52/255, 0},
    },

    --https://lospec.com/palette-list/endesga-32
    endesga32 = {
        wall = {color.unpack_rgb(0xbe4a2f)},
        goal = {color.unpack_rgb(0x63c74d)},
        player_inner = {color.unpack_rgb(0x181425)},
        player_outer = {color.unpack_rgb(0xfee761)},
        player_diamond = {color.unpack_rgb(0x124e89)},
        explosion_inner = {color.unpack_rgb(0x181425)},
        breakable = {color.unpack_rgb(0xc28569)},
        bomb_pulse_outer = {color.unpack_rgb(0xe43b44)},
        bomb_pulse_inner = {color.unpack_rgb(0xa22633)},
    },

    --https://lospec.com/palette-list/sad
    sad = {
        wall = {color.unpack_rgb(0x40342f)},
        goal = {color.unpack_rgb(0xa3ccab)},
        player_inner = {color.unpack_rgb(0x1a1618)},
        player_outer = {color.unpack_rgb(0x5d4561)},
        player_diamond = {color.unpack_rgb(0x73728f)},
        explosion_inner = {color.unpack_rgb(0x1a1618)},
        breakable = {color.unpack_rgb(0x769ea6)},
        bomb_pulse_outer = {color.unpack_rgb(0x73728f)},
        bomb_pulse_inner = {color.unpack_rgb(0x769ea6)},
    },
}

local levels_palette = {
    [1] = "default",
    [2] = "endesga32",
    [3] = "sad",
}

function Themes.on_change_level(level_number)
    if levels_palette[level_number] then
        Themes.change_palette(levels_palette[level_number])
    end
end

function Themes.change_palette(id)
    assert(palettes[id], id .. " must exists in the palettes table")
    current = id
end

function Themes.get_color(id, alpha)
    assert(palettes[current][id], id .. " must exists in the current palette")
    local color = palettes[current][id]
    return {color[1], color[2], color[3], alpha or color[4]}
end

function Themes.get_color_raw(id, alpha)
    assert(palettes[current][id], id .. " must exists in the current palette")
    return unpack(Themes.get_color(id, alpha))
end

function Themes.set_color(id, alpha)
    assert(palettes[current][id], id .. " must exists in the current palette")
    local color = palettes[current][id]
    love.graphics.setColor(color[1], color[2], color[3], alpha or color[4])
end

return Themes
