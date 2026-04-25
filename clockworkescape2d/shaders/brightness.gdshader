shader_type canvas_item;

uniform float brightness : hint_range(-1.0, 1.0) = 0.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
	color.rgb += brightness;
	COLOR = color;
}