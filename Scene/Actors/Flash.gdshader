shader_type canvas_item;

uniform vec4 flash_color : hint_color = vec4(1.0);
uniform float mix_amount = 0.0;

void fragment(){
	vec4 color = texture(TEXTURE, UV);
	if (color.a != 0.0){
		COLOR = mix(flash_color, color, 1.0 - mix_amount);
	} else {
		COLOR = color;
	} 
}