shader_type spatial;

render_mode depth_prepass_alpha, unshaded;

uniform vec4 albedo : source_color;
uniform sampler2D texture_blast;
uniform float width : hint_range(0.0, 1.0) = 0.75;
uniform float threshold : hint_range(0.0, 1.0) = 0.0;

void vertex() {
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0],INV_VIEW_MATRIX[1],INV_VIEW_MATRIX[2],MODEL_MATRIX[3]);
}

void fragment() {
	vec4 blast_tex = texture(texture_blast, UV);
	ALBEDO = albedo.rgb;
	float gradient = (width * 2.0 + 1.0) * threshold - width;
	gradient = abs(blast_tex.g - gradient) / width * 2.0;
	gradient = clamp(gradient, 0.0, 1.0);
	gradient = smoothstep(0.0, 1.0, gradient);
	ALPHA = clamp(blast_tex.r - gradient, 0.0, 1.0);
}
