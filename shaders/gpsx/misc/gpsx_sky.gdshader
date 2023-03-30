shader_type sky;

group_uniforms Texture;
uniform sampler2D tex : source_color, hint_default_white, filter_nearest;
uniform vec4 mixer : source_color = vec4(1.0);
group_uniforms;

group_uniforms Accuracy;
uniform bool dithering = true;
uniform bool banding = true;
group_uniforms;

const float neareight = 255.0;

// Note: Based off emulator PS1 GPU code
// It's widespread enough you need to only look at your favorite one's
vec3 dither(vec3 col, uvec2 fc)
{
    const int mat[16] = int[16] (
        -4, 0, -3, 1,
        2, -2, 3, -1,
        -3, 1, -4, 0,
        3, -1, 2, -2
    );

    ivec3 uncol = ivec3(col * neareight) + mat[(fc.y & uint(3)) * uint(4) + (fc.x & uint(3))];
    return vec3(uncol) / neareight;
}

const float finaldepth = 32.0;

// I have no need for anything under/around 15-bit
// If higher, only 24-bit, and at that point just disable
// it lol
vec3 band_color(vec3 lol)
{
	ivec3 res = ivec3(clamp(lol, 0.0, 1.0) * neareight) & ivec3(0xFF);
	ivec3 ires = res >> 3;
	ivec3 dres = res & ivec3(7);
	res = (ires << 3) | dres;
	return vec3(res) / neareight;
}

void sky() {
	COLOR = texture(tex, SKY_COORDS).rgb * mixer.rgb;
	if(dithering)
		COLOR = dither(COLOR, uvec2(FRAGCOORD.xy));
	if(banding)
		COLOR = band_color(COLOR);
	
}
