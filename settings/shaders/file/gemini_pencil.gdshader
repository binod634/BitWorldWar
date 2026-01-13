shader_type canvas_item;

// --- Uniforms ---
uniform vec4 ink_color : source_color = vec4(0.1, 0.05, 0.05, 1.0);
uniform float line_thickness : hint_range(0.0, 5.0) = 1.0;
uniform float hatching_density : hint_range(1.0, 100.0) = 50.0;
uniform float jitter_speed : hint_range(0.0, 20.0) = 5.0;
uniform float jitter_intensity : hint_range(0.0, 0.01) = 0.002;
uniform sampler2D parchment_tex : filter_linear_mipmap, repeat_enable;

// Function to create hatching lines
float get_hatch(vec2 uv, float brightness) {
    float line = sin((uv.x + uv.y) * hatching_density);
    float hatch = smoothstep(0.0, 0.1, line);
    // Darker areas get more hatching
    return mix(1.0, hatch, 1.0 - smoothstep(0.3, 0.6, brightness));
}

void vertex() {
    // Jitter the vertices slightly to simulate "hand-drawn boiling"
    float t = TIME * jitter_speed;
    VERTEX.x += sin(t + VERTEX.y * 10.0) * jitter_intensity * 100.0;
    VERTEX.y += cos(t + VERTEX.x * 10.0) * jitter_intensity * 100.0;
}

void fragment() {
    // 1. Sample texture with a slight UV offset for jitter
    vec2 jitter_uv = UV + vec2(sin(TIME * jitter_speed), cos(TIME * jitter_speed)) * jitter_intensity;
    vec4 tex_color = texture(TEXTURE, jitter_uv);
    
    // 2. Convert to Grayscale (Brightness)
    float brightness = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
    
    // 3. Simple Edge Detection (Outline)
    vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;
    float edge = 0.0;
    edge += texture(TEXTURE, jitter_uv + vec2(size.x, 0)).a;
    edge += texture(TEXTURE, jitter_uv - vec2(size.x, 0)).a;
    edge += texture(TEXTURE, jitter_uv + vec2(0, size.y)).a;
    edge += texture(TEXTURE, jitter_uv - vec2(0, size.y)).a;
    
    float outline = (edge < 4.0 && tex_color.a > 0.1) ? 1.0 : 0.0;
    
    // 4. Combine Hatching and Inking
    float hatch = get_hatch(SCREEN_UV, brightness);
    
    // 5. Blending with Parchment
    vec4 paper = texture(parchment_tex, SCREEN_UV);
    
    // Final ink calculation:
    // If it's an outline, use ink color. 
    // If it's dark, use hatching. 
    // Otherwise, let the paper show through.
    float final_ink = mix(hatch, 0.0, outline);
    
    vec4 final_color = mix(ink_color, paper, final_ink);
    
    // Keep the original sprite's transparency
    final_color.a *= tex_color.a;
    
    COLOR = final_color;
}