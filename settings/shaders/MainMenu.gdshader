shader_type canvas_item;

uniform float rust_strength : hint_range(0.0, 1.0);  // Controls how much rust to apply
uniform sampler2D rust_texture :hint_default_white;  // Rust texture
uniform float rust_speed : hint_range(0.0, 1.0);  // Optional: Controls rust speed, can animate
uniform float rust_offset : hint_range(0.0, 1.0);  // Optional: Controls the offset of the rust texture

void fragment() {
    // Get the base texture color (button color, background, etc.)
    vec4 tex_color = texture(TEXTURE, UV);

    // Sample the rust texture at the given UV coordinates, with optional offset and speed
    vec4 rust = texture(rust_texture, (UV + rust_offset) * 3.0); // 3.0 is for scaling the rust texture, adjust it
    rust.a *= rust_strength; // Control the transparency of the rust effect

    // Blend the rust with the base texture (e.g., the button's normal state)
    vec4 final_color = mix(tex_color, tex_color + rust, rust_strength);

    // Output the final color (blended rust and base texture)
    COLOR = vec4(0.9,0.0,0.0,0.5);
}
