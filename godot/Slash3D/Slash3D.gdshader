// ANCHOR: shader_type
shader_type spatial;

render_mode blend_add, cull_disabled, unshaded;
// END: shader_type
// ANCHOR: uniforms
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform float emission_energy;
uniform float alpha_offset : hint_range(0,1);
// END: uniforms
// ANCHOR: fragment
void fragment() {
	vec4 albedo_tex = texture(texture_albedo, UV);
	ALBEDO = albedo.rgb * albedo_tex.rgb * emission_energy;
	ALPHA = max(albedo_tex.a - alpha_offset, 0.0);
}
// END: fragment