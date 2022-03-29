shader_type spatial;

render_mode depth_draw_alpha_prepass, unshaded;

uniform sampler2D erosion_texture;
uniform sampler2D pattern_texture;

uniform float erosion_smooth : hint_range(0.0,  1.0) = 0.1;
uniform float fire_smooth : hint_range(0.0,  1.0) = 0.1;
uniform vec4 smoke_color : hint_color;
uniform vec4 emission_color : hint_color;
uniform float uv_offset = 0.0;
uniform float displacement : hint_range(0.0, 1.0) = 0.0;
uniform float movement_driver : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D movement_curve;
uniform sampler2D fire_curve;
uniform sampler2D erosion_curve;
uniform float offset : hint_range(0.0, 1.0) = 0.2;
uniform float dissapation_offset : hint_range(0.0, 1.0) = 0.2;

varying float movement;

void vertex() {
	float disp_noise = texture(pattern_texture, UV + vec2(0.0, uv_offset)).r;
	movement = movement_driver * (1.0 + offset) - (1.0 - COLOR.r) * offset;
	VERTEX *= texture(movement_curve, vec2(movement)).r;
	VERTEX += NORMAL * disp_noise * displacement;
}

void fragment() {
	float dissapation = movement_driver * (1.0 + dissapation_offset) - COLOR.g * dissapation_offset;
	float erosion_noise = texture(erosion_texture, UV * 2.0 + vec2(0.0 + COLOR.g, uv_offset + COLOR.g)).r;
	float fire_noise = texture(pattern_texture, UV + vec2(0.0 + COLOR.g, uv_offset + COLOR.g)).r;
	float fresnel = dot(NORMAL, VIEW);
	fire_noise = fire_noise * fresnel + fresnel * .2;
	erosion_noise = erosion_noise * fresnel;
	
	float fire_value = 1.0 - texture(fire_curve, vec2(movement)).r;
	float erosion_value = texture(erosion_curve, vec2(dissapation)).r;
	float fire_smoothmix = smoothstep(fire_value - fire_smooth, fire_value + fire_smooth, fire_noise);
	float erosion_smoothmix = smoothstep(erosion_value - erosion_smooth, erosion_value + erosion_smooth, erosion_noise);
	ALBEDO = mix(smoke_color.rgb, emission_color.rgb, fire_smoothmix);
	ALPHA = erosion_smoothmix;
}