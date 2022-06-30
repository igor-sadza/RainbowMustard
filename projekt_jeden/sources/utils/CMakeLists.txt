add_library(utils "")

target_sources(utils
	PRIVATE
		SharedResources.cpp
		Settings.cpp
		FileParser.cpp
		PrimitiveRenderer.cpp
	PUBLIC
		${CMAKE_CURRENT_LIST_DIR}/CommonIncludes.hpp
		${CMAKE_CURRENT_LIST_DIR}/SharedResources.hpp
		${CMAKE_CURRENT_LIST_DIR}/Settings.hpp
		${CMAKE_CURRENT_LIST_DIR}/FileParser.hpp
		${CMAKE_CURRENT_LIST_DIR}/PrimitiveRenderer.hpp
	)

target_include_directories(utils
	PUBLIC
		${CMAKE_CURRENT_LIST_DIR}
	)

target_link_libraries(utils
	PRIVATE
		external
	)
