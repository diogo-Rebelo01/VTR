#version 330

uniform vec4 water;
uniform mat4 m_view;
uniform vec4 l_dir;
uniform float opacity;

in Data {
	vec3 normal;
	vec4 vertex;
} DataIn;

out vec4 color;


void main() {
	vec3 n = normalize(DataIn.normal);
	vec3 l = normalize(vec3(m_view * l_dir));

	float intensity = max(dot(n, l), 0.0);
	
	//color = max(intensity, 0.25) * vec4(water.xyz,0);
	color = vec4(water.xyz,opacity);
}