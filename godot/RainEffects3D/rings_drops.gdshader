shader_type spatial;

uniform vec4 albedo : hint_color = vec4(0.0, 0.0, 0.0, 0.3);
uniform float roughness : hint_range(0.0, 1.0) = 0.2;
uniform float normal_scale : hint_range(-16.0, 16.0) = 1.0;

uniform float ring_width : hint_range(0.0, 1.0) = 0.1;
uniform float ring_fadeout : hint_range(0.0, 1.0) = 0.6;
uniform float ring_scale : hint_range(0.1, 8.0) = 1.0;

uniform float drop_speed : hint_range(0.1, 2.0) = 1.0;
uniform float drop_scale : hint_range(0.1, 8.0) = 1.0;

uniform sampler2D ring_pattern_texture;
uniform sampler2D drop_texture;
uniform sampler2D drop_uv_texture;

void vertex() {
	TANGENT = vec3(0.0, 0.0, -1.0) * abs(NORMAL.x);
	TANGENT += vec3(1.0, 0.0, 0.0) * abs(NORMAL.y);
	TANGENT += vec3(1.0, 0.0, 0.0) * abs(NORMAL.z);
	TANGENT = normalize(TANGENT);
	BINORMAL = vec3(0.0, 1.0, 0.0) * abs(NORMAL.x);
	BINORMAL += vec3(0.0, 0.0, -1.0) * abs(NORMAL.y);
	BINORMAL += vec3(0.0, 1.0, 0.0) * abs(NORMAL.z);
	BINORMAL = normalize(BINORMAL);
}

void fragment() {
	// We make the triplaner mapping world space by converting
	// NORMAL and VERTEX to world space in the lines below
	// We calculate these in the fragment shader instead of 
	// the vertex shader for nicer interpolation
	vec3 uv_power_normal = pow(abs(mat3(CAMERA_MATRIX) * NORMAL), vec3(50.0));
	uv_power_normal /= dot(uv_power_normal, vec3(1.0));
	vec3 uv_triplanar_pos = (CAMERA_MATRIX * vec4(VERTEX, 1.0)).xyz;
	uv_triplanar_pos *= vec3(1.0,-1.0, 1.0);
	
	// Top Rings
	vec4 ring_pattern = texture(ring_pattern_texture, uv_triplanar_pos.xz / ring_scale);
	
	float fct_time = fract(TIME + ring_pattern.a);
	float fade = (1.0 - fct_time / ring_fadeout);
	
	float grad_inner = ring_pattern.b;
	grad_inner -= fct_time;
	grad_inner /= ring_width / 2.0;
	grad_inner = clamp(grad_inner, 0.0, 1.0);
	float ring_inner = smoothstep(0.0, 1.0, min(grad_inner, (1.0 - grad_inner)) * 2.0);
	ring_inner = clamp(ring_inner, 0.0, 1.0);
	
	float grad_outer = ring_pattern.b;
	grad_outer -= fct_time + ring_width / 2.0;
	grad_outer /= ring_width / 2.0;
	grad_outer = clamp(grad_outer, 0.0, 1.0);
	float ring_outer = smoothstep(0.0, 1.0, min(grad_outer, (1.0 - grad_outer)) * 2.0);
	ring_outer = clamp(ring_outer, 0.0, 1.0);
	
	float grad = ring_pattern.b;
	grad -= fct_time;
	grad /= ring_width;
	grad = clamp(grad, 0.0, 1.0);
	float ring = smoothstep(0.0, 1.0, min(grad, (1.0 - grad)) * 2.0);
	ring *= fade;
	ring = clamp(ring, 0.0, 1.0);
	
	// As our normal map is for the inside of the ring, we make an inverted
	// version for the outside by unpacking, multiplying by -1.0 and repacking
	vec2 inverted_rings_normal_map = (((ring_pattern.rg * 2.0 - 1.0) * -1.0) + 1.0) / 2.0; 
	vec3 rings_normal_map = mix(vec3(0.5, 0.5, 0.0), vec3(ring_pattern.rg, 0.0), ring_inner);
	rings_normal_map = mix(rings_normal_map, vec3(inverted_rings_normal_map, 0.0), ring_outer);
	rings_normal_map.z = ring;
	
	// Running Drops
	vec4 rain_uv_xy = texture(drop_uv_texture, uv_triplanar_pos.xy / drop_scale);
	rain_uv_xy.y = uv_triplanar_pos.y / drop_scale;
	vec4 rain_uv_zy = texture(drop_uv_texture, uv_triplanar_pos.zy / drop_scale);
	rain_uv_zy.y = uv_triplanar_pos.y / drop_scale;
	rain_uv_xy.y += (sin(TIME + rain_uv_xy.b * 6.28) * 0.1 * rain_uv_xy.b - TIME * rain_uv_xy.b * .35) * drop_speed;
	rain_uv_zy.y += (sin(TIME + rain_uv_zy.b * 6.28) * 0.1 * rain_uv_zy.b - TIME * rain_uv_zy.b * .35) * drop_speed;
	
	vec4 drops_pattern_xy = texture(drop_texture, rain_uv_xy.rg);
	vec4 drops_pattern_zy = texture(drop_texture, rain_uv_zy.rg);
	
	vec4 drops_pattern = mix(drops_pattern_xy, drops_pattern_zy, uv_power_normal.x);
	drops_pattern = mix(drops_pattern, vec4(0.5, 0.5, 0.0, 1.0), uv_power_normal.y);
	
	// Combine
	float top_mask = smoothstep(1.0, 0.5, dot(mat3(CAMERA_MATRIX) * NORMAL, vec3(0.0, 1.0, 0.0)));
	vec3 combined = mix(rings_normal_map, drops_pattern.rgb, top_mask);
	
	ROUGHNESS = roughness;
	NORMALMAP = combined;
	NORMALMAP_DEPTH = normal_scale;
	ALBEDO = albedo.rgb;
	ALPHA = combined.b * albedo.a;
}
