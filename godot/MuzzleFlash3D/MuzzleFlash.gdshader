shader_type spatial;

render_mode cull_disabled, unshaded, blend_add;
const float TAU = 6.283185307179586;

uniform sampler2D muzzle_pattern;
uniform sampler2D colorize_gradient : hint_albedo;
uniform float rate_of_fire = 10.0;
uniform float fresnel_threshold : hint_range(0.0, 1.0) = 0.5;
uniform float size_randomization : hint_range(0.0, 1.0) = 0.3;
uniform sampler2D scale_curve;

// Common pseudo random function
float random (float seed) {
	return fract(sin(dot(vec2(seed),vec2(12.9898,78.233))) * 43758.5453123);
}

// Rodrigues' rotation formula
vec3 rotate (vec3 v, vec3 n, float a) {
	return v * cos(a) + cross(n, v) * sin(a) + n * dot(n, v) * (1.0 - cos(a));
}

// ANCHOR: vertex_function
void vertex() {
	// The mesh's origin in world space
	vec3 origin = (WORLD_MATRIX * vec4(0, 0, 0, 1)).xyz;
	float unique_seed = origin.x + origin.y + origin.z;
	float random_value = random(floor(TIME * rate_of_fire) + unique_seed);
	VERTEX = rotate(VERTEX, vec3(0.0, 1.0, 0.0), random_value * TAU);
	// We must rotate the normal the same as the vertex to be able to calculate fresnel later
	NORMAL = rotate(NORMAL, vec3(0.0, 1.0, 0.0), random_value * TAU);
	VERTEX *= 1.0 + (random_value * 2.0 - 1.0) * size_randomization;
	// The fract function gets our progress through the current scale curve animation.
	float curve = texture(scale_curve, vec2(fract(TIME * rate_of_fire))).r;
	VERTEX *= curve;
}
// END: vertex_function

void fragment() {
	float muzzle_tex = texture(muzzle_pattern, UV).r;
	vec4 muzzle_color = texture(colorize_gradient, vec2(muzzle_tex));
	ALBEDO = muzzle_color.rgb;
	float fresnel = smoothstep(0.0, fresnel_threshold, dot(NORMAL, VIEW));
	// Multiply alpha by a fresnel effect to hide the texture cards when their
	// surface is almost aligned to the camera view
	ALPHA = muzzle_color.a * fresnel;
}
