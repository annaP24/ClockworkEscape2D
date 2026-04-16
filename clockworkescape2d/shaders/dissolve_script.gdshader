shader_type canvas_item;

uniform sampler2D noise_tex;
uniform sampler2D gradient_tex;
uniform float change_point : hint_range(0,1)= 0;
uniform vec4 edge_color : source_color;
uniform vec4 base_color : source_color; 

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	//COLOR = base_color;
	vec4 noise_pixel = texture(noise_tex, UV);
	vec4 gradient_pixel = texture(gradient_tex, UV);
	float sum = mix(noise_pixel.r, gradient_pixel.r, 0.5);
	// same as sum >= change_point
	float alpha = step(change_point,sum);
	
	float edge_mask = smoothstep(change_point + 0.3, change_point, sum);
	//edge_mask *= alpha;
	vec3 final_color = mix(COLOR.rgb,edge_color.rgb, edge_mask);
	COLOR = vec4(final_color, alpha);
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
