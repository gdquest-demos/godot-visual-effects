shader_type spatial;
render_mode unshaded;

uniform vec4 color: hint_color = vec4(1.0);

void fragment() {
	ALBEDO = color.rgb;
}