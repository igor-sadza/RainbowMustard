add_library(managers "")

target_sources(managers
	PRIVATE
	PUBLIC
	${CMAKE_CURRENT_LIST_DIR}/PiecesManager.hpp
	)

target_include_directories(managers
	PUBLIC
		${CMAKE_CURRENT_LIST_DIR}
	)
	
target_link_libraries(managers
	PRIVATE
		utils
	)
