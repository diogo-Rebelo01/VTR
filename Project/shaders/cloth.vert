#version 460

// uniforms
uniform mat4 m_pvm;
uniform mat3 m_normal;
uniform mat4 m_viewModel;
uniform vec4 l_pos;

// input streams - local space
in vec4 position;
in vec3 normal;
in vec2 texCoord0;

//output
out vec3 n; // normal in camera space
out vec3 e; // eye vector in camera space
out vec4 l_dir;
out vec2 tc;

void main() {

    // normalize to ensure correct direction when interpolating
    tc = texCoord0;
    n = normalize(m_normal * normal);

    l_dir = position - l_pos;

    e = vec3(- m_viewModel * position); //converter para o espaço da camara e fazer contas
    
    gl_Position = m_pvm * position;
}