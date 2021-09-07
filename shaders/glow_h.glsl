const vec3 weights = vec3(0.45, 0.10, 0.45);

vec4 effect(vec4 color, Image texture, vec2 uv, vec2 sc)
{
	vec4 c = vec4(0.0);
	for(int i = 0; i <= 2; i++){
		vec2 suv = (vec2(float(i) - 1.0) + sc)/love_ScreenSize.xy;
		c += Texel(texture, suv) * weights[i];
	}
	return vec4(c.xyz, 1.0);
}
