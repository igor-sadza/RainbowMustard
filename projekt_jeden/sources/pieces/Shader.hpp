#ifndef SHADER_HPP
#define SHADER_HPP

#include "CommonIncludes.hpp"

class Shader {
	private:
		template<class Type_0, std::size_t Number, class Type_1>
		auto MakeArray(Type_1 t_variable) -> std::array<Type_0, Number>;

		std::vector<std::string>	m_shaderNames;
		unsigned			m_shaderObject;
		unsigned 			m_shaderProgram;
		std::string 			m_shaderName;

		void link();
		void init(const std::string &t_shaderSource);
	public:
		Shader(const std::string t_shaderName);

		void UseShader();
		std::string GetShaderName();

		template<class Type>
		void SendVariable(const std::string &t_uniformName, Type t_variable);
};

#include "Shader.hxx"

#endif //SHADER_HPP
