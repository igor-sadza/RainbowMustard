add_library(states "")

target_sources(states
	PRIVATE
		StateSwitcher.cpp
		StateManager.cpp
		StateLogo.cpp
		StateMenu.cpp
	PUBLIC
		${CMAKE_CURRENT_LIST_DIR}/StateSwitcher.hpp
		${CMAKE_CURRENT_LIST_DIR}/State.hpp
		${CMAKE_CURRENT_LIST_DIR}/StateManager.hpp
		${CMAKE_CURRENT_LIST_DIR}/StateLogo.hpp
		${CMAKE_CURRENT_LIST_DIR}/StateMenu.hpp
	)	

target_include_directories(states
	PUBLIC
		${CMAKE_CURRENT_LIST_DIR}
	)
	
target_link_libraries(states
	PRIVATE
		utils
		external
	)
