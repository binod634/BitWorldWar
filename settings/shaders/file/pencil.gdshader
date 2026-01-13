shader_type canvas_item;

float getIntensity(vec3 color)
{
    return 0.299 * color.r + 0.587 * color.g + 0.114 * color.b;
}

void fragment()
{
    // Use the declared screen_texture sampler
    vec4 origColor = texture(TEXTURE, UV);
    float intensity = getIntensity(origColor.rgb);
    // COLOR = vec4(origColor.r,origColor.g,origColor.b,0.5);
    COLOR = vec4(intensity,intensity,intensity,0.5);
    // COLOR = getPatternColor(UV, intensity);

    // vec4 bgColor = mix(texture(u_bgTexture, UV * u_bgTiling), u_bgColor, u_bgColorFactor);
    // vec4 patternColor = getPatternColor(UV, intensity);

    // vec4 color = mix(u_patternColor, bgColor, getIntensity(patternColor.rgb));
    // COLOR = color;
}
