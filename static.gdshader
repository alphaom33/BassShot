shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

float rand(vec2 uv) {
	return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 size = vec2(textureSize(TEXTURE, 0));
	vec2 grid_size = size / 1.0;
	vec2 new_uv = floor(UV * grid_size) / grid_size;
	COLOR = vec4(vec3(rand(new_uv + vec2(TIME, 0.0))), 1.0);
	//COLOR = vec4(vec3(rand((vec2(round(UV.x / 7.0), round(UV.y / 7.0))) * 7.0)), 1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
