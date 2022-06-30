add_library(external "")

target_sources(external
	PRIVATE
		${CMAKE_CURRENT_LIST_DIR}/glad.c
		${CMAKE_CURRENT_LIST_DIR}/stb_image.cpp
	PUBLIC

		${CMAKE_CURRENT_LIST_DIR}/glad.h
		${CMAKE_CURRENT_LIST_DIR}/stb_image.h
	)

target_include_directories(external
	PUBLIC
		${CMAKE_CURRENT_LIST_DIR}
	)
