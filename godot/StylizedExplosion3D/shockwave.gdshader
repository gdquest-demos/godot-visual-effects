shader_type spatial;

render_mode depth_draw_alpha_prepass, unshaded;

uniform vec4 albedo : hint_color;
uniform sampler2D noise_texture;
uniform float erosion : hint_range(0.0, 1.0) = 0.0;
uniform float erosion_width : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	float fresnel = dot(NORMAL, VIEW);
	float noise = texture(noise_texture, UV).r;
	float mask = (1.0 - fresnel) - noise * .4;

	ALPHA = smoothstep(erosion - erosion_width, erosion + erosion_width, mask) * albedo.a;
	ALBEDO = albedo.rgb;
}