#version 330

uniform vec4 WATER;
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
	

	float intensity = max(0.0, dot(n, l));
	
	color = max(intensity, 0.5) * vec4(WATER.xyz,opacity);
	//color = vec4(water.xyz,opacity);
}