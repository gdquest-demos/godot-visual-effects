shader_type spatial;

uniform sampler2D albedo_texture : hint_albedo;
uniform sampler2D normal_texture : hint_normal;
uniform float roughness : hint_range(0.0, 1.0) = 0.5;
uniform vec2 uv_scale = vec2(4.0, 1.0);
uniform float growth = 1.0;
uniform float thickness : hint_range(0.0, 1.0) = 0.25;
uniform float sss_strength : hint_range(0.0, 1.0) = 0.3;

varying float offset;

void vertex() {
	float uneven_growth = (growth * 2.0 - 1.0) - COLOR.r;
	uneven_growth = min(0.0, uneven_growth);
	offset = UV.x;
	offset += uneven_growth;
	VERTEX -= NORMAL * 0.1; // subtract original model thickness
	VERTEX += NORMAL * thickness * offset;
}

void fragment() {
	if (offset < 0.0) {
		discard;
	}
	ALBEDO = texture(albedo_texture, UV + vec2(offset, 0.0) * uv_scale).rgb;
	NORMALMAP = texture(normal_texture, UV + vec2(offset, 0.0) * uv_scale).rgb;
	ROUGHNESS = roughness;
	SSS_STRENGTH = sss_strength;
}