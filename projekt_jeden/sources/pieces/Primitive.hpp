#ifndef PRIMITIVE_HPP
#define PRIMITIVE_HPP

#include "CommonIncludes.hpp"

class Primitive {
	private:
		template<class Type>
		struct Implementation {
			template<class Arg>
			static Type ParasePointers(const Arg &t_arg, int t_argSize);
			
			template<class... Args>
			static Type CreateVector(Args... t_args);	
		};

		glm::vec2 m_primitiveSize;
		glm::vec2 m_primitivePosition;
		glm::vec4 m_primitiveColor;
	public:
		Primitive();

		template<class... Args>
		void SetPrimitiveSize(Args... t_args);

		template<class... Args>
		void SetPrimitivePosition(Args... t_args);

		template<class... Args>
		void SetPrimitiveColor(Args... t_args);

		glm::vec2 &GetPrimitiveSize();
		glm::vec2 &GetPrimitivePosition();
		glm::vec4 &GetPrimitiveColor();
};

#include "Primitive.hxx"

#endif //PRIMITIVE_HPP
