shader_type canvas_item;

uniform vec4 halo_color: hint_color = vec4(1.0);
// Length of the bounding square in pixels. Set from GDScript.
uniform float bounds_half_length = 1.0;
// Size of the gradient in pixels.
uniform float halo_radius = 12.0;

void fragment() {
	float dist = distance(UV, vec2(0.5, 0.5));
	float radius_uv = 1.0 / bounds_half_length * halo_radius;
	float halo_mask = pow(smoothstep(0.5 - radius_uv, 0.5, dist), 4.0);
	float circle_mask = 1.0 - smoothstep(0.48, 0.5, dist);
	
	COLOR.a = halo_mask * circle_mask;
	COLOR.rgb = halo_color.rgb;
	COLOR.a *= halo_color.a;
}