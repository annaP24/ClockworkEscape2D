shader_type canvas_item;

uniform float brightness : hint_range(-0.5, 0.5) = 0.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
	// Multiplicative brightness preserves colors and hues better
	// brightness of 0.0 = 1.0x (no change)
	// brightness of 0.5 = 1.5x (50% brighter)
	// brightness of -0.5 = 0.5x (50% darker)
	color.rgb *= (1.0 + brightness);
	COLOR = color;
}