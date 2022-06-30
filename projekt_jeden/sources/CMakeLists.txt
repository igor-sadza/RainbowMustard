add_executable(projektJeden main.cpp)

add_subdirectory(utils)
add_subdirectory(states)
add_subdirectory(pieces)

target_link_libraries(projektJeden
	PRIVATE
		external
		utils
		states
		pieces
	)
