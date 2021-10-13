local ripple = require "source.lib.ripple"

local audio = {}

local menu = love.audio.newSource("assets/sokobomb_ingame_a.mp3", "stream")
local game = love.audio.newSource("assets/sokobomb_menu_b.mp3", "stream")
local sounds = { menu = ripple.newSound(menu, { loop = true }), game = ripple.newSound(game, { loop = true }) }

function audio.update(dt)
    for _, sound in pairs(sounds) do
        sound:update(dt)
    end
end

function audio.play(track, options)
    sounds[track]:play(options)
end

function audio.pause(track, fade)
    sounds[track]:pause(fade)
end

function audio.resume(track, fade)
    sounds[track]:resume(fade)
end

function audio.stop(track, fade)
    sounds[track]:stop(fade)
end

return audio
