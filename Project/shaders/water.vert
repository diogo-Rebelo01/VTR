#version 330

uniform	mat4 m_pvm;
uniform mat3 m_normal;

uniform float water_level;

in vec4 position;
in vec3 normal;

out Data {
    vec3 normal;
	vec4 vertex;
} DataOut;


void main() {	
	DataOut.normal = normalize(m_normal * normal);

	vec4 vertex = (position + vec4(0.0, water_level, 0.0, 1.0));
	DataOut.vertex = vertex;

	gl_Position = m_pvm * vertex;
}