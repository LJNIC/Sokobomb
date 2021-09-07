const vec3 weights = vec3(.45,.10,.45);

vec4 effect(vec4 color, Image texture, vec2 uv, vec2 sc){
	vec4 c = vec4(0.);
	for(int i = 0; i <= 2; i++){
		vec2 suv = (vec2(1.-float(i), float(i)-1.) + sc)/love_ScreenSize.xy;
		c += Texel(texture, suv)*weights[i];
	}
	return vec4(c.xyz,1.);
}
