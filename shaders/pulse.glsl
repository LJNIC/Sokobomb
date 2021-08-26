extern float pct;
extern vec2 translate;
extern vec2 pos;
extern vec2 size;

vec4 effect(vec4 color, Image texture, vec2 tex_coords, vec2 screen_coords)
{
	vec2 new_uv = (screen_coords - translate - pos)/size;
	vec4 px = Texel(texture, new_uv);
	return px * pct * color;
}
