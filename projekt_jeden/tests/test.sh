[VERTEX_SHADER]
#version 330 core

layout(location = 0) in vec4 t_verticies;

uniform mat4 t_projection;
uniform mat4 t_model;

void main() {
	gl_Position = t_projection * t_model * vec4(t_verticies.xy, 0.0f, 1.0f);
};

[FRAGMENT_SHADER]
#version 330 core

out vec4 m_color;
uniform t_color = vec4(1.0f);

void main() {
	m_color = t_color;
};
