extern Image tex;
extern float pct;
extern vec2 translate;
extern vec2 pos;
extern vec2 size;

extern vec4 f_color;
extern vec4 o_color;

vec4 effect(vec4 color, Image texture, vec2 uv, vec2 screen_coords)
{
	//for whole screen
	vec2 new_uv = screen_coords/love_ScreenSize.xy;
	vec4 fade = Texel(tex, new_uv);

	//for singular rect
	/* vec2 new_uv = (screen_coords - translate - pos)/size; */
	/* vec4 px = Texel(tex, new_uv); */

	vec4 pixel = Texel(texture, uv);
	vec4 c = mix(f_color, o_color, float(fade.r > pct));

	return c * pixel * color;

	/* if (fade.r > pct) */
	/* 	return pixel * color; */
	/* else */
	/* 	return f_color; */
}
