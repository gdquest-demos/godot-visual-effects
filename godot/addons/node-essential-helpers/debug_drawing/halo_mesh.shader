shader_type spatial;
render_mode depth_draw_opaque, cull_disabled, ambient_light_disabled, blend_add, shadows_disabled;

uniform vec4 halo_color : hint_color;
uniform float fresnel_power = 1.0;
uniform float edge_intensity = 0.5;

void fragment() {
	//Create a fresnel effect from the NORMAL and VIEW vectors.
	float fresnel = pow(1.0 - dot(NORMAL, VIEW), fresnel_power) * edge_intensity;
	
	//Get the raw linear depth from the depth texture into a  [-1, 1] range
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r * 2.0 - 1.0;
	//Recreate linear depth of the intersecting geometry using projection matrix, and subtract the vertex of the sphere
	depth = PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]) + VERTEX.z;
	//Intensity intersection effect
	depth = pow(1.0 - clamp(depth, 0, 1), fresnel_power) * edge_intensity;
	
	//Calculate final alpha using fresnel and depth joined together
	fresnel = fresnel + depth;

	//Apply final color
	ALBEDO = vec3(0);
	EMISSION = halo_color.rgb;
	ALPHA = smoothstep(0.0, 1.0, fresnel);
}