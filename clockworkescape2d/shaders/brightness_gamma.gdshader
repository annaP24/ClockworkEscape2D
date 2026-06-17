shader_type canvas_item;

uniform float gamma : hint_range(0.5, 2.0) = 1.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
void fragment() {
    vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
    color.rgb = pow(color.rgb, vec3(1.0 / gamma));
    COLOR = color;
}