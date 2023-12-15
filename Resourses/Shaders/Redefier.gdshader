shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if(COLOR.r==1.0 && COLOR.g==1.0 && COLOR.b==1.0){
		COLOR.b=0.0;
		COLOR.g=0.0;
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
