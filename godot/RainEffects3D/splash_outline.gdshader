shader_type spatial;
render_mode cull_front;

uniform vec4 albedo : hint_color = vec4(1.0);
uniform float height : hint_range(0.0, 2.0) = 0.5;
uniform float roughness : hint_range(0.0, 1.0) = 0.2;
uniform float normal_strength : hint_range(-16.0, 16.0) = 1.0;
uniform float frame_rate : hint_range(6.0, 60.0, 1.0) = 12.0;
uniform float splash_size : hint_range(0.1, 8.0) = 1.0;
uniform float refraction : hint_range(-16,16) = 0.05;
uniform sampler2D splashes_texture;
uniform sampler2D profile_noise_texture;

varying float distance_to_camera;

void vertex() {
	// We round the value so it only changes the uv scale of the rain in big steps
	distance_to_camera = length( (MODELVIEW_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz );
	distance_to_camera = round(distance_to_camera);
	
	float z_mask = step(0.0, ( mat3(WORLD_MATRIX) * NORMAL).y);
	VERTEX += (vec4(0.0, height, 0.0, 0.0) * WORLD_MATRIX).xyz * z_mask;
}

void fragment() {
	float time = fract(floor(TIME * frame_rate) / frame_rate);
	vec3 splashes = texture(splashes_texture, -SCREEN_UV * vec2(1.0, VIEWPORT_SIZE.y / VIEWPORT_SIZE.x) * distance_to_camera / splash_size + vec2(time * 37.21, -time * 12.34)).rgb;
	float fresnel = max(0.0, dot(NORMAL, VIEW));
	float profile_noise = texture(profile_noise_texture, -SCREEN_UV * vec2(1.0, VIEWPORT_SIZE.y / VIEWPORT_SIZE.x) * distance_to_camera).r;
	
	// Refraction
	vec3 unpacked_normal = NORMALMAP;
	unpacked_normal.xy = unpacked_normal.xy * 2.0 - 1.0;
	unpacked_normal.z = sqrt(max(0.0, 1.0 - dot(unpacked_normal.xy, unpacked_normal.xy)));
	vec3 ref_normal = normalize( mix(NORMAL,TANGENT * unpacked_normal.x + BINORMAL * unpacked_normal.y + NORMAL * unpacked_normal.z, NORMALMAP_DEPTH) );
	vec2 ref_ofs = SCREEN_UV - ref_normal.xy * refraction;
	float ref_amount = 1.0 - albedo.a;
	
	ALBEDO = albedo.rgb;
	ALBEDO *= 1.0 - ref_amount;
	NORMAL = VIEW;
	NORMALMAP = splashes * normal_strength;
	ROUGHNESS = roughness;
	EMISSION += textureLod(SCREEN_TEXTURE, ref_ofs, ROUGHNESS * 8.0).rgb * ref_amount;
	ALPHA = max(0.0, smoothstep(0.0, 0.5, fresnel) * splashes.b - profile_noise);
}