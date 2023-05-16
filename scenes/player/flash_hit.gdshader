shader_type canvas_item;

uniform float lerp_percent : hint_range(0.0, 1.0) = 0;
uniform vec4 color : source_color;
uniform float alpha : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec4 texture_color = texture(TEXTURE, UV);
	vec4 final_color = mix(vec4(texture_color.r, texture_color.g, texture_color.b, texture_color.a * alpha), vec4(color.r, color.g, color.b, texture_color.a * alpha), lerp_percent);
	COLOR = final_color;
}
