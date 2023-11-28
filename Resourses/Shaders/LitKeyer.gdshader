shader_type canvas_item;

	uniform sampler2D lit_mask;

void fragment() {
	vec4 mask=texture(lit_mask, UV);
	
	
	//vec4 col=texture(TEXTURE, UV);
	COLOR.a=1.0-mask.r;
	//COLOR=COLOR;
	//COLOR=mask;
}
