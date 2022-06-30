#include "Shader.hpp"
#include "Settings.hpp"
#include "FileParser.hpp"
//Private
void Shader::link() {
	int 	success;
	char 	infoLog[512];

	glAttachShader(m_shaderProgram, m_shaderObject);
	glLinkProgram(m_shaderProgram);
	glGetProgramiv(m_shaderObject, GL_COMPILE_STATUS, &success);

	if(!success) {
		glGetProgramInfoLog(m_shaderProgram, sizeof(infoLog), NULL, infoLog);
		std::cout << infoLog << std::endl;
		std::runtime_error(std::string(infoLog));	
	};
	glDeleteShader(m_shaderObject);
};
void Shader::init(const std::string &t_shaderSource) {
	int 		success;
	char 		infoLog[512];
	const char 	*src = t_shaderSource.c_str();

	glShaderSource(m_shaderObject, 1, &src, NULL);
	glCompileShader(m_shaderObject);
  	glGetShaderiv(m_shaderObject, GL_COMPILE_STATUS, &success);

  	if (!success) {
  	  glGetShaderInfoLog(m_shaderObject, 512, NULL, infoLog);
  	  std::cout << infoLog << std::endl;
  	  std::runtime_error(std::string(infoLog));
  	}
};
//Public
Shader::Shader(const std::string t_shaderName)
	: m_shaderName(t_shaderName)
	, m_shaderObject(0)
	, m_shaderNames({"VERTEX_SHADER", "FRAGMENT_SHADER", "GEOMETRY_SHADER"}) {

	m_shaderProgram = glCreateProgram();
	FileParser fp(t_shaderName);

	for(auto& ite: m_shaderNames) {
		if(!fp.getSource(ite).empty()) {
			if(ite == "VERTEX_SHADER") {
				m_shaderObject = glCreateShader(GL_VERTEX_SHADER);
			} else
			if(ite == "FRAGMENT_SHADER") {
				m_shaderObject = glCreateShader(GL_FRAGMENT_SHADER);
			} else
			if(ite == "GEOMETRY_SHADER") {
				m_shaderObject= glCreateShader(GL_GEOMETRY_SHADER);
			}
			init(fp.getSource(ite));
			link();
		};
	};

	glm::mat4 projectionMatrix = glm::ortho(0.0f, WindowSettings::windowWidth, WindowSettings::windowHeight, 0.0f, -1.0f, 0.0f);

	UseShader();
	SendVariable("t_projection", projectionMatrix);
};

void Shader::UseShader() {
	glUseProgram(m_shaderProgram);
};

std::string Shader::GetShaderName() {
	return m_shaderName;
};

