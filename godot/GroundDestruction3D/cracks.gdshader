shader_type spatial;

uniform sampler2D effect_texture : hint_black;
uniform vec4 albedo : hint_color = vec4(1.0);
uniform float roughness : hint_range(0.0, 1.0) = 1.0;

uniform int depth_max_layers = 32;
uniform int depth_min_layers = 8;
uniform float depth_scale = 0.05;

uniform float offset = 0.0;
uniform float fade = 0.0;

void fragment() {
	
	float gradient = texture(effect_texture, UV / vec2(3.0, 1.0) - vec2(offset, 0.0)).a + fade;
	
		vec2 base_uv = UV;
	{
		vec3 view_dir = normalize(normalize(-VERTEX) * mat3(TANGENT, -BINORMAL, NORMAL));
		float num_layers = mix(float(depth_max_layers),float(depth_min_layers), abs(dot(vec3(0.0, 0.0, 1.0), view_dir)));
		float layer_depth = 1.0 / num_layers;
		float current_layer_depth = 0.0;
		vec2 P = view_dir.xy * depth_scale;
		vec2 delta = P / num_layers;
		vec2 ofs = base_uv;
		float depth = (textureLod(effect_texture, ofs, 0.0).b - .9) / .1;
		float current_depth = 0.0;
		while(current_depth < depth) {
			ofs -= delta;
			depth = (textureLod(effect_texture, ofs, 0.0).b - .9) / .1;
			current_depth += layer_depth;
		}
		vec2 prev_ofs = ofs + delta;
		float after_depth  = depth - current_depth;
		float before_depth = ((textureLod(effect_texture, prev_ofs, 0.0).b - .9) / .1) - current_depth + layer_depth;
		float weight = after_depth / (after_depth - before_depth);
		ofs = mix(ofs,prev_ofs,weight);
		base_uv=ofs;
	}
	
	vec4 pattern = texture(effect_texture, base_uv);
	
	ALBEDO = albedo.rgb;
	NORMALMAP = pattern.rgb;
	ALPHA = texture(effect_texture, UV).b;
	ALPHA_SCISSOR = 0.9 + gradient * 0.4;
}