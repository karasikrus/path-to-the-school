shader_type canvas_item;
uniform sampler2D dissolve_pattern;
uniform sampler2D dissolve_pattern_extra;
uniform float dissolve_state : hint_range(0.0, 1.01) = 0;

void fragment() {
//	COLOR = texture(TEXTURE, UV);
	float pattern_value = texture(dissolve_pattern,  UV).r;
	float extra_pattern_value = texture(dissolve_pattern_extra,  UV).r;
	COLOR.a *= step(dissolve_state, pattern_value * extra_pattern_value);
}
