shader_type spatial;
//render_mode cull_disabled;
render_mode world_vertex_coords;

uniform sampler2D albedo_texture : source_color;
uniform sampler2D normal_texture : hint_normal;
uniform float roughness : hint_range(0.0, 1.0) = 0.5;
uniform vec2 uv_scale = vec2(4.0, 1.0);
uniform float growth = 1.0;
uniform float thickness : hint_range(0.0, 1.0) = 0.25;
uniform float sss_strength : hint_range(0.0, 1.0) = 0.3;

varying float displacement;

void vertex() {
	float uneven_growth = (growth * 2.0 - 1.0) - COLOR.r;
	displacement = UV.x + min(0.0, uneven_growth);
	// subtract original model's thickness
	//VERTEX -= NORMAL * 0.1;
	//VERTEX += NORMAL * thickness * displacement;
}

//Some parts render above others when they shouldn't
// no idea which pass that would be...
void fragment() {
	if (displacement < 0.0) {
		discard;
	}
	vec2 offset_uv = UV + vec2(displacement, 0.0) * uv_scale;
	ALBEDO = texture(albedo_texture, offset_uv).rgb;
	NORMAL_MAP = texture(normal_texture, offset_uv).rgb;
	ROUGHNESS = roughness;
	//SSS_STRENGTH = sss_strength;
	
	//ALPHA = 1.0;	//ok...
}