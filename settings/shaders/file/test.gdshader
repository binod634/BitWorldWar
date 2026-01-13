shader_type canvas_item;

// Textures for the effect
uniform sampler2D screen_texture : hint_screen_texture;
uniform sampler2D hatch_texture; // A texture with pencil scratch/hatch marks
uniform float sketch_intensity : hint_range(0.0, 1.0) = 0.5;
uniform float edge_roughness : hint_range(0.0, 10.0) = 2.0;
uniform vec4 pencil_color : source_color = vec4(0.1, 0.1, 0.1, 1.0);

// Function to create a pseudo-random value for edge distortion
float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    // 1. Distort UVs slightly to make the polygon edges look "hand-drawn"
    vec2 roughness = vec2(random(UV + TIME * 0.05)) * 0.001 * edge_roughness;
    vec2 distorted_uv = UV + roughness;
    
    // 2. Get the original texture/color
    vec4 tex_color = texture(TEXTURE, distorted_uv);
    
    // 3. Calculate "Luminance" (How bright the pixel is)
    // Even if it's a white polygon, we use this for the hatch density
    float luma = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
    
    // 4. Sample the hatch texture
    // We tile it based on screen coordinates so patterns stay consistent across objects
    vec2 hatch_uv = SCREEN_UV * 5.0; 
    float hatch = texture(hatch_texture, hatch_uv).r;
    
    // 5. Create the sketch logic
    // If the pixel is dark (or we want more detail), show more hatch marks
    float sketch_line = smoothstep(luma, luma + 0.5, hatch * sketch_intensity);
    
    // 6. Combine
    vec3 final_color = mix(pencil_color.rgb, tex_color.rgb, sketch_line);
    
    // Apply transparency from the original polygon
    COLOR = vec4(final_color, tex_color.a);
}