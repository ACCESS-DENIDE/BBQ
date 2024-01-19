shader_type canvas_item;

render_mode light_only;

uniform float scale:hint_range(0.0, 10.0, 0.01);

void light(){
	
	vec2 coord= FRAGCOORD.xy;
	vec2 light=LIGHT_POSITION.xy;
	
	coord.x=coord.x*scale;
	coord.y=coord.y*scale;
	
	light.x=light.x*scale;
	light.y=light.y*scale;
	
	vec4 col =COLOR;
	
	vec2 at =screen_uv_to_sdf(SCREEN_UV);
	float len=length(light-coord);
	vec2 step_size=normalize(light-coord);
	
	if(LIGHT_COLOR.r==0.0){
		col.w=0.0;
	}
	else{
		col.w=LIGHT_COLOR.r;
		for (float i=0.0; i<len; i++){
			if(texture_sdf(at)<0.0){
				col.w=0.0;
				break;
			}
			at=at+step_size;
		}
	}
	LIGHT=col;
}