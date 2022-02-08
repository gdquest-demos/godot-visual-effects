shader_type spatial;
render_mode unshaded;

const float TAU = 6.283185307179586;

uniform vec4 albedo : hint_color;

uniform sampler2D fire_gradient : hint_albedo;
uniform sampler2D texture_pattern;

uniform int particles_h_frames;
uniform int particles_v_frames;

uniform float warp_strength : hint_range(0.0, 0.1) = 0.025;
uniform float warp_speed : hint_range(0.0, 16.0) = 8.0;
uniform float warp_scale : hint_range(0.0, 2.0) = 0.5;

void vertex() {
	mat4 mat_world = mat4(
			normalize(CAMERA_MATRIX[0])*length(WORLD_MATRIX[0]),
			normalize(CAMERA_MATRIX[1])*length(WORLD_MATRIX[0]),
			normalize(CAMERA_MATRIX[2])*length(WORLD_MATRIX[2]),
			WORLD_MATRIX[3]);
	
	mat_world = mat_world * mat4(
			vec4(cos(INSTANCE_CUSTOM.x), -sin(INSTANCE_CUSTOM.x), 0.0, 0.0),
			vec4(sin(INSTANCE_CUSTOM.x), cos(INSTANCE_CUSTOM.x), 0.0, 0.0),
			vec4(0.0, 0.0, 1.0, 0.0),
			vec4(0.0, 0.0, 0.0, 1.0));
	
	MODELVIEW_MATRIX = INV_CAMERA_MATRIX * mat_world;
	
	float h_frames = float(particles_h_frames);
	float v_frames = float(particles_v_frames);
	float particle_total_frames = float(particles_h_frames * particles_v_frames);
	float particle_frame = floor(INSTANCE_CUSTOM.z * float(particle_total_frames));
	UV /= vec2(h_frames, v_frames);
	UV += vec2(mod(particle_frame, h_frames) / h_frames, floor((particle_frame + 0.5) / h_frames) / v_frames);
}

void fragment() {
	// The particle decreases its alpha linearly over time, making a useful value for progress
	float animation_progress = 1.0 - COLOR.a;
	
	// We want the amount we warp the texture on the x-axis to vary depending how far along the
	// y-axis we are and vice versa. So UV.y is used for the x_warp and UV.x is used for the  y_warp
	float x_warp = animation_progress * warp_speed + UV.y * TAU / warp_scale;
	float y_warp = animation_progress * warp_speed + UV.x * TAU / warp_scale;
	
	vec2 distortion_offset = vec2(sin(x_warp), sin(y_warp)) * warp_strength;
	float pattern = texture(texture_pattern, UV + distortion_offset).r;
	
	// Erode the pattern as the animation progresses
	pattern = clamp(pattern - animation_progress, 0.0, 1.0);
	vec4 gradient_color = texture(fire_gradient, vec2(pattern));
	
	ALBEDO = gradient_color.rgb * albedo.rgb;
	ALPHA = pattern;
}
