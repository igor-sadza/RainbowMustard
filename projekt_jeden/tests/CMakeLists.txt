add_executable(testCPP main.cpp)

file(GLOB MY_TXT_FILES
	${CMAKE_CURRENT_SOURCE_DIR}/*.cfg
	${CMAKE_CURRENT_SOURCE_DIR}/*.sh
)

file(COPY ${MY_TXT_FILES} DESTINATION ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR}/ConfigFiles/) 

target_link_libraries(testCPP 
		external
		utils
		states		
		pieces
	)

add_test(
	NAME
		test_evolution
	COMMAND
		$<TARGET_FILE: main.cpp>
	)
