shader_type canvas_item;

//Shader that displays the main viewport, but uses the displacement mask to
//distort the UVs and generate a shockwave or heattrail-like effect.

uniform float displacement_amount = 5.0;
uniform sampler2D displacement_mask;

void fragment() {
	float uv_displace_amount = displacement_amount * 1.0 / float(textureSize(TEXTURE, 0).x);
	vec4 displacement = texture(displacement_mask, UV);
	vec2 displacement_uv = UV + displacement.xy * uv_displace_amount;
	COLOR = texture(TEXTURE, displacement_uv);
}