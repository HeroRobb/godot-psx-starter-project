shader_type spatial;
render_mode skip_vertex_transform, diffuse_lambert_wrap, unshaded, cull_disabled;

uniform vec4 mixer : source_color = vec4(1.0);
uniform sampler2D tex;
uniform bool dithering = true;
uniform bool banding = true;

const float psx_fixed_point_precision = 16.16;
void vertex()
{
	// Vertex snapping
	// based on https://github.com/BroMandarin/unity_lwrp_psx_shader/blob/master/PS1.shader
	float vertex_snap_step = psx_fixed_point_precision * 2.0;
	vec4 snap_to_pixel = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	vec4 clip_vertex = snap_to_pixel;
	clip_vertex.xyz = snap_to_pixel.xyz / snap_to_pixel.w;
	clip_vertex.x = floor(vertex_snap_step * clip_vertex.x) / vertex_snap_step;
	clip_vertex.y = floor(vertex_snap_step * clip_vertex.y) / vertex_snap_step;
	clip_vertex.xyz *= snap_to_pixel.w;
	POSITION = clip_vertex;
	POSITION /= abs(POSITION.w);

	VERTEX = VERTEX;  // it breaks without this
	NORMAL = (MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
}

const float neareight = 255.0;

// Note: Based off emulator PS1 GPU code
// It's widespread enough you need to only look at your favorite one's
vec3 dither(vec3 col, uvec4 fc)
{
	const int mat[16] = int[16] (
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
	ALBEDO = COLOR.rgb;
	ALBEDO *= (texture(tex, UV) * mixer).rgb;
	if(dithering)
		ALBEDO = dither(ALBEDO, uvec4(FRAGCOORD));
	if(banding)
		ALBEDO = band_color(ALBEDO);
}