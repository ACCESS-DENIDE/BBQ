shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if(COLOR.x==1.0 && COLOR.y==1.0 && COLOR.z==1.0){
		COLOR.x=0.0;
		COLOR.y=0.0;
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
