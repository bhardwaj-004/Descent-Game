shader_type canvas_item;

uniform float progress: hint_range(0.0, 1.0) = 0.0;
uniform vec3 color_picked: source_color = vec3(1.0, 0.0, 0.0);

void fragment() {
	float silhouette_alpha = texture(TEXTURE, UV * 1.0 + 0.001).a;
	vec4 color_silhouette = vec4(color_picked, silhouette_alpha);
	COLOR = mix(COLOR, color_silhouette, progress * (1.5 - COLOR.a));
	// Called for every pixel the material is visible on.
}
