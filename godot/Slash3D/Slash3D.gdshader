shader_type spatial;

render_mode blend_add, cull_disabled, unshaded;
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform float emission_energy;
uniform float alpha_offset : hint_range(0,1);


void fragment() {
	vec4 albedo_tex = texture(texture_albedo, UV);
	ALBEDO = albedo.rgb * albedo_tex.rgb * emission_energy;
	ALPHA = max(albedo_tex.a - alpha_offset, 0.0);
}
