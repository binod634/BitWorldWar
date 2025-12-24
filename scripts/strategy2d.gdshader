shader_type canvas_item;

uniform float world_width : hint_range(1.0, 10000.0) = 1280.0;

varying vec2 world_uv;

void vertex() {
    world_uv = world_uv / world_width;
}

void fragment() {
    vec2 uv = vec2(fract(world_uv.x), UV.y);
    COLOR = texture(TEXTURE, uv);
}
