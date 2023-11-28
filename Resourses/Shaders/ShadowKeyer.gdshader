shader_type canvas_item;


uniform vec4 key_color : source_color;
render_mode light_only;

void light() {
	vec4 col=COLOR;
	if(LIGHT_COLOR==key_color){
		col.w=0.0;
	}
	
	
	LIGHT=col;
}