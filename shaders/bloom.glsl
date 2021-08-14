extern vec2 canvas_size;
extern int samples = 5;
extern float qual = 1.5;

vec4 effect(vec4 color, Image texture, vec2 tex_coords, vec2 screen_coords)
{
	vec4 pixel = Texel(texture, screen_coords/love_ScreenSize.xy);
	//vec4 pixel = Texel(texture, tex_coords);
	vec4 sum = vec4(0);
	int diff = (samples - 1)/2;
	vec2 f = vec2(1)/canvas_size * qual;

	for (int x = -diff; x <= diff; ++x)
	{
		for (int y = -diff; y <= diff; ++y)
		{
			vec2 off = vec2(x, y) * f;
			//sum += Texel(texture, tex_coords + off);
			sum += Texel(texture, screen_coords/love_ScreenSize.xy + off);
		}
	}

	return ((sum/(samples * samples)) + pixel) * color;
}
