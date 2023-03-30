shader_type spatial;
render_mode skip_vertex_transform, unshaded, cull_disabled, blend_mix;

instance uniform vec4 mixer : source_color = vec4(1.0);

group_uniforms Texture;
uniform sampler2D tex : source_color, hint_default_white, filter_nearest;
uniform float alpha_cutoff : hint_range(0.0, 1.0, 0.01) = 0.1;
group_uniforms;

group_uniforms Accuracy;
uniform float psx_fixed_point_precision = 48.16;
uniform bool dithering = true;
uniform bool banding = true;
group_uniforms;

group_uniforms Fog;
uniform bool fog = false;
uniform vec3 fog_color : source_color = vec3(0.0);
uniform float dist_fade_min = 0.0;
uniform float dist_fade_max = 10.0;
group_uniforms;

varying flat float dist;
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
    NORMAL = (MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	
	if (fog)
		dist = length(clip_vertex);
}

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

void fragment(){
    vec4 col = (texture(tex, UV) * mixer) * COLOR;
    if (col.a < alpha_cutoff)
        discard;
	if (fog)
		col.rgb = mix(col.rgb, fog_color, clamp(smoothstep(dist_fade_min, dist_fade_max, dist), 0.0, 1.0));
	ALBEDO = col.rgb;
    if(dithering)
        ALBEDO = dither(ALBEDO, uvec2(FRAGCOORD.xy));
    if(banding)
        ALBEDO = band_color(ALBEDO);
	ALPHA = 0.5;
}