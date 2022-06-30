#ifndef PRIMITIVE_RENDERER_HPP
#define PRIMITIVE_RENDERER_HPP

class PrimitiveRenderer {
	private:
		PrimitiveRenderer();
		static unsigned m_vao;
		static unsigned m_vbo;
	public:
		static PrimitiveRenderer &initRenderer();
		static void renderPrimitive();
};

#endif // PRIMITIVE_RENDERER_HPP
