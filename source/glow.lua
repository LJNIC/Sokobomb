local moonshine = require "source.lib.moonshine"

local Glow = {}

Glow.bloom = moonshine(moonshine.effects.glow)
Glow.bloom.glow.min_luma = 0.2 --lower is more glow
Glow.bloom.glow.strength = 5 --higher is larger glow
Glow.bloom.glow.dir = {0.25, 0.1} --direction (x, y) 0.0 to 1.0 range

return Glow
