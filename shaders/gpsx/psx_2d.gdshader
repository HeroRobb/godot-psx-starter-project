shader_type canvas_item;

uniform vec4 mixer : source_color = vec4(1.0);
uniform bool dithering = true;
uniform bool banding = true;

const float neareight = 255.0;

// Note: Based off emulator PS1 GPU code
// It's widespread enough you need to only look at your favorite one's
vec3 dither(vec3 col, uvec4 fc)
{
	int mat[16] = int[16] (
		-4, 0, -3, 1,
		2, -2, 3, -1,
		-3, 1, -4, 0,
		3, -1, 2, -2
	);
	
	ivec3 uncol = ivec3(col * neareight) + mat[(fc.y & uint(3)) * uint(4) + (fc.x & uint(3))];
	uncol = clamp(uncol, ivec3(0), ivec3(255));
	return vec3(uncol) / neareight;
}

const float finaldepth = 32.0;

// I have no need for anything under/around 15-bit
// If higher, only 24-bit, and at that point just disable
// it lol
vec3 band_color(vec3 col)
{
	return floor(col * (finaldepth - 1.0) + 0.5) / (finaldepth - 1.0);
}

void fragment(){
	COLOR.rgb = (texture(TEXTURE, UV) * mixer).rgb;
	if(dithering)
		COLOR.rgb  = dither(COLOR.rgb, uvec4(FRAGCOORD));
	if(banding)
		COLOR.rgb = band_color(COLOR.rgb);
}