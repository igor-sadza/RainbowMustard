#include "Primitive.hpp"

template<class Type>
template<class Arg>
Type Primitive::Implementation<Type>::ParasePointers(const Arg &t_arg, int t_argSize) {

	int returnTypeSize = sizeof(Type) / sizeof(1);
	auto *firstElement = (float *)((void *)t_arg.begin());

	Type result;

	for (int i = 0; i < returnTypeSize; i++) {
		(i < t_argSize)
		? result[i] = *(firstElement++)
		: result[i] = *(firstElement-1);	
	};
	
	return result;
};

template<class Type>
template<class... Args>
Type Primitive::Implementation<Type>::CreateVector(Args... t_args) {

	auto arguments = {t_args...};
	int scalarsCount = 0;
	int vecCount = 0;

	for (auto &ite: arguments) {
		(sizeof(ite) / sizeof(float) == 1)
		? scalarsCount++
		: vecCount++;
	};

	int scalarsFromVec = sizeof(*arguments.begin()) / sizeof(1.0f);

	return (vecCount >= 1)
	? Implementation<Type>::ParasePointers(arguments, scalarsFromVec)
	: Implementation<Type>::ParasePointers(arguments, scalarsCount);

};

template<class... Args>
void Primitive::SetPrimitiveSize(Args... t_args) {
	m_primitiveSize = Implementation<glm::vec2>::CreateVector(t_args...);
};

template<class... Args>
void Primitive::SetPrimitivePosition(Args... t_args) {
	m_primitivePosition = Implementation<glm::vec2>::CreateVector(t_args...);
};

template<class... Args>
void Primitive::SetPrimitiveColor(Args... t_args) {
	m_primitiveColor = Implementation<glm::vec4>::CreateVector(t_args...);
};
