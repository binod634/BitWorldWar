shader_type canvas_item;

void fragment() {
	//vec2 position = vec2(UV.x,UV.y + sin(TIME)*0.05 + UV.y * 0.95) ;
	COLOR = texture(TEXTURE,UV);
}

void vertex()  {
	 VERTEX += vec2(VERTEX.x, sin(TIME)*10.0);
}