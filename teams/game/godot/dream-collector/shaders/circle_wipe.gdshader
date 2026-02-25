// circle_wipe.gdshader
// Circle transition shader (iris wipe effect)
// Fixed aspect ratio for perfect circle

shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec2 center = vec2(0.5, 0.5);  // Center position (normalized 0-1)
uniform float smoothness : hint_range(0.0, 0.1) = 0.02;
uniform vec2 screen_size = vec2(390.0, 844.0);  // Actual screen size for aspect ratio

void fragment() {
    // Get normalized UV coordinates
    vec2 uv = UV;
    
    // Calculate aspect ratio (width / height)
    float aspect = screen_size.x / screen_size.y;  // 390/844 = 0.462
    
    // Adjust UV coordinates to maintain circular shape
    // Since height > width, compress Y to make it circular
    vec2 adjusted_uv = uv;
    adjusted_uv.y = (uv.y - 0.5) * aspect + 0.5;
    
    vec2 adjusted_center = center;
    adjusted_center.y = (center.y - 0.5) * aspect + 0.5;
    
    // Calculate distance from center (now correctly circular)
    float dist = distance(adjusted_uv, adjusted_center);
    
    // Maximum possible distance (from center to corner)
    float max_dist = length(vec2(0.5, 0.5 * aspect));
    
    // Normalize distance (0 at center, 1 at corners)
    float normalized_dist = dist / max_dist;
    
    // Calculate alpha based on progress
    // progress 0.0 = fully visible (black screen)
    // progress 1.0 = fully transparent (reveal scene)
    float alpha = smoothstep(progress - smoothness, progress + smoothness, normalized_dist);
    
    // Output black color with calculated alpha
    COLOR = vec4(0.0, 0.0, 0.0, alpha);
}
