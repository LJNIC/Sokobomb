vec4 effect(vec4 color, Image texture, vec2 uv, vec2 sc)
{
	vec4 c = Texel(texture, uv);

	for (float i = 0; i <= 2; i++)
	{
		for (float j = 0; j <= 2; j++)
		{
			vec2 suv = (normalize(vec2(i - 1.0, j - 1.0)) + sc)/love_ScreenSize.xy;
			c = max(Texel(texture, suv) * 0.77, c);
		}
	}

	return vec4(c.xyz, 1.0);
}
