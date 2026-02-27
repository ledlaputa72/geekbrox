shader_type canvas_item;

uniform vec3 chroma_color = vec3(1.0, 0.0, 1.0);
uniform float threshold = 0.35;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	float d = distance(c.rgb, chroma_color);
	if (d < threshold) {
		c.a = 0.0;
	}
	COLOR = c;
}
