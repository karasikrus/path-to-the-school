shader_type canvas_item;

uniform float lerp_percent : hint_range(0.0, 1.0);
uniform vec4 color : source_color;

void fragment() {
	vec4 texture_color = texture(TEXTURE, UV);
	vec4 finnal_color = mix(texture_color, vec4(color.r, color.g, color.b, texture_color.a), lerp_percent);
	COLOR = finnal_color;
}
