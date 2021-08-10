extern Image tex;
extern float pct;
extern vec4 f_color;

vec4 effect(vec4 color, Image texture, vec2 tex_coords, vec2 screen_coords)
{
	vec4 px = Texel(tex, screen_coords/love_ScreenSize.xy);
	if (px.r > pct)
		return Texel(texture, tex_coords) * color;
	else
		return f_color;
}
