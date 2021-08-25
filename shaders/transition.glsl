extern Image tex;
extern float pct;
extern vec4 f_color;
extern vec2 translate;
extern vec2 pos;
extern vec2 size;

vec4 effect(vec4 color, Image texture, vec2 tex_coords, vec2 screen_coords)
{
	//for whole screen
	vec2 new_uv = (screen_coords)/love_ScreenSize.xy;
	vec4 px = Texel(tex, new_uv);

	//for singular rect
	/* vec2 new_uv = (screen_coords - translate - pos)/size; */
	/* vec4 px = Texel(tex, new_uv); */

	if (px.r > pct)
		return Texel(texture, tex_coords) * color;
	else
		return f_color;
}
