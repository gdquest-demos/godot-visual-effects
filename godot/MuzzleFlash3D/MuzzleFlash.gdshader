shader_type spatial;
render_mode blend_mix, depth_draw_alpha_prepass, cull_disabled, unshaded;
uniform vec4 albedo : hint_color = vec4(1.0);
uniform sampler2D texture_albedo : hint_albedo;
uniform float rate_of_fire = 10.0;
uniform float size_randomization : hint_range(0.0, 1.0) = 0.3;
uniform sampler2D scale_curve;

// Common pseudo random function
float random (float seed) {
    return fract(sin(dot(vec2(seed),
                         vec2(12.9898,78.233)))*
        43758.5453123);
}

// Rodrigues' rotation formula
vec3 rotate (vec3 v, vec3 n, float a) {
    return v * cos(a) + cross(n, v) * sin(a) + n * dot(n, v) * (1. - cos(a));
}


void vertex() {
	float TAU = 6.283185307179586;
	vec3 origin = (WORLD_MATRIX * vec4(0, 0, 0, 1)).xyz;
	float unique_seed = origin.x + origin.y + origin.z;
	float random_value = random( floor((TIME * rate_of_fire)) + unique_seed );
	VERTEX = rotate(VERTEX, vec3(0.0, 1.0, 0.0), random_value * TAU);
	// We must rotate the normal the same as the vertex to be able to calculate fresnel later
	NORMAL = rotate(NORMAL, vec3(0.0, 1.0, 0.0), random_value * TAU);
	VERTEX *= 1.0 + (random_value * 2.0 - 1.0) * size_randomization;
	float curve = texture(scale_curve, vec2(fract((TIME * rate_of_fire)), 0.0)).r;
	VERTEX *= curve;
}


void fragment() {
	vec4 albedo_tex = texture(texture_albedo, UV);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	float fresnel = clamp(pow(dot(NORMAL, VIEW) * 2.0, 4.0), 0.0, 1.0);
	// Multiply alpha by a fresnel effect to hide the texture cards when their
	// surface is almost aligned to the camera view
	ALPHA = max(0.0, albedo.a - (1.0 - albedo_tex.a)) * fresnel;
}
