shader_type spatial;

uniform vec4 albedo_rock : hint_color = vec4(1.0);
uniform float roughness : hint_range(0.0, 1.0) = 1.0;

uniform vec3 bb_start;
uniform vec3 bb_size;

uniform float animation_driver = 0.0;
uniform float appear_percentage = 0.25;
uniform float randomness = 0.05;
uniform sampler2D scale_curve_rock : hint_black;
uniform sampler2D shake_curve : hint_black;
uniform sampler2D timing_curve : hint_black;

float rand(vec3 p) {
	return fract(sin(dot(p,vec3(127.1,311.7, 74.7)))*43758.5453123);
}

void vertex() {
	vec3 positions = vec3(COLOR.r, 0.0, COLOR.g) * bb_size + bb_start;
	float seed = rand(positions);
	float offset_time = TIME + seed;
	float timing = texture(timing_curve, vec2(COLOR.r, 0.0)).r;
	float offset_driver = animation_driver * (1.0 + appear_percentage) - timing * appear_percentage + (seed - 0.5) * randomness;
	float shake = texture(shake_curve, vec2( offset_driver, 0.0 )).r;
	
	VERTEX += vec3(sin(offset_time * 50.0), sin(offset_time * 44.0), sin(offset_time * 68.0)) *.02 * (1.0 - COLOR.b) * shake;
	VERTEX -= positions;
	VERTEX *= texture(scale_curve_rock, vec2( offset_driver, 0.0 )).r * 1.4;
	VERTEX += positions;
}

void fragment() {
	ALBEDO = albedo_rock.rgb;
	ROUGHNESS = roughness;
}