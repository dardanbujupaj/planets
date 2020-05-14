shader_type spatial;
render_mode cull_front, unshaded;

uniform float outline_width : hint_range(0.01, 0.1) = 0.1;
uniform vec4 color : hint_color = vec4(1.0, 1.0, 1.0, 1.0);

void vertex() {
	VERTEX += (NORMAL * outline_width);
}

void fragment() {
	ALBEDO = color.rbg;
}