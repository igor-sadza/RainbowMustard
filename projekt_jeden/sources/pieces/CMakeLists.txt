add_library(pieces "")

target_sources(pieces
	PRIVATE
		Glyph.cpp
		Primitive.cpp
		Shader.cpp
		Sprite.cpp
	PUBLIC
	${CMAKE_CURRENT_LIST_DIR}/Glyph.hpp
	${CMAKE_CURRENT_LIST_DIR}/Primitive.hpp
	${CMAKE_CURRENT_LIST_DIR}/Shader.hpp
	${CMAKE_CURRENT_LIST_DIR}/Sprite.hpp
	)

target_include_directories(pieces
	PUBLIC
		${CMAKE_CURRENT_LIST_DIR}
	)
	
target_link_libraries(pieces
	PRIVATE
		utils
		external
	)
