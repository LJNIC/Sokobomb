local ripple = require "source.lib.ripple"

local audio = {}

local master = ripple.newTag()
local game = love.audio.newSource("assets/sokobomb_ingame_a.mp3", "stream")
local menu = love.audio.newSource("assets/sokobomb_menu_b.mp3", "stream")
local sounds = { 
   menu = ripple.newSound(menu, { loop = true , tags = {master} }), 
   game = ripple.newSound(game, { loop = true, volume = 0.4, tags = {master} }) 
}
local muted = false

function audio.update(dt)
    for _, sound in pairs(sounds) do
        sound:update(dt)
    end
end

function audio.play(track, options)
    if not muted then
        sounds[track]:play(options)
    end
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

function audio.mute()
    muted = not muted
    if muted then
       master:pause()
    else
       master:resume()
    end
end

return audio
