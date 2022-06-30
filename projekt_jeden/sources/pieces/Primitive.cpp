#include "Primitive.hpp"

Primitive::Primitive() {

};

glm::vec2 &Primitive::GetPrimitiveSize() {
	return m_primitiveSize;
};

glm::vec2 &Primitive::GetPrimitivePosition() {
	return m_primitivePosition;
};

glm::vec4 &Primitive::GetPrimitiveColor() {
	return m_primitiveColor;
};
