shader_type canvas_item;

uniform bool is_clicked = false;

void fragment() {
	if (is_clicked) {
		COLOR.rgb = COLOR.rgb * 0.5;
	}
}