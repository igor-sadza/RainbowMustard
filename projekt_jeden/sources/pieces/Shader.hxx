#include "Shader.hpp"

template <class Type_0, std::size_t Number, class Type_1>
auto Shader::MakeArray(Type_1 t_var) -> std::array<Type_0, Number> {

  std::array<Type_0, Number> result;
  float *p = (float *)(void *)(&t_var);
  for (int i = 0; i < Number; i++) {
    result[i] = *p++;
  }
  return result;
}

template <class Type>
void Shader::SendVariable(const std::string &t_uniformName, Type t_value) {

  UseShader();
  int location = glGetUniformLocation(m_shaderProgram, t_uniformName.c_str());

  if (typeid(Type) == typeid(float)) {
    auto array = MakeArray<float, 1>(t_value);
    glUniform1f(location, array[0]);
  } 
  else 
  if (typeid(Type) == typeid(glm::vec2)) {
    auto array = MakeArray<float, 2>(t_value);
    glUniform2f(location, array[0], array[1]);
  } 
  else 
  if (typeid(Type) == typeid(glm::vec3)) {
    auto array = MakeArray<float, 3>(t_value);
    glUniform3f(location, array[0], array[1], array[2]);
  } 
  else 
  if (typeid(Type) == typeid(glm::vec4)) {
    auto array = MakeArray<float, 4>(t_value);
    glUniform4f(location, array[0], array[1], array[2], array[3]);
  } 
  else 
  if (typeid(Type) == typeid(glm::mat4)) {
    auto array = MakeArray<float, 16>(t_value);
    glUniformMatrix4fv(location, 1, GL_FALSE,
                       glm::value_ptr(glm::make_mat4(&array[0])));
  }
}
