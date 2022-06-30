#include "CommonIncludes.hpp"
#include "SharedResources.hpp"
#include "Settings.hpp"
#include "StateSwitcher.hpp"

namespace InputCallbacks {
	void keyboardKeyCallback(GLFWwindow *t_window, GLint t_key, GLint t_scanCode, GLint t_action, GLint t_mods);
	void mouseKeyCallback(GLFWwindow *t_window, GLint t_key, GLint t_action, GLint t_mods);
	void mousePositionCallback(GLFWwindow *t_window, GLdouble t_posX, GLdouble t_posY);
}; // namespace InputCallbacks

int main() {
	//Init glfw
	glfwInit();
	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
	glfwWindowHint(GLFW_RESIZABLE, GLFW_FALSE);
	
	//Create window
	 SharedResoureces::window = glfwCreateWindow(WindowSettings::windowWidth, WindowSettings::windowHeight, WindowSettings::windowName, NULL, NULL);
	 glfwMakeContextCurrent(SharedResoureces::window);

	//Load OpenGL functions
	gladLoadGLLoader((GLADloadproc)glfwGetProcAddress); 
	
	//Viewport
	glViewport(0, 0, WindowSettings::windowWidth, WindowSettings::windowHeight);

	//Blending settings
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	//Input Callbacks
	glfwSetMouseButtonCallback(SharedResoureces::window, InputCallbacks::mouseKeyCallback);
	glfwSetKeyCallback(SharedResoureces::window, InputCallbacks::keyboardKeyCallback);
	glfwSetCursorPosCallback(SharedResoureces::window, InputCallbacks::mousePositionCallback);

	StateSwitcher::initSwitcher();

	//Game loop
	while(!glfwWindowShouldClose(SharedResoureces::window)) {
		glfwPollEvents();	

		glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
		glClear(GL_COLOR_BUFFER_BIT);

		StateSwitcher::selectedStateBackground();
		StateSwitcher::seletecStateLogic();
		StateSwitcher::selectedStateRender();

		glfwSwapBuffers(SharedResoureces::window);
		glfwPollEvents();	
	}

	glfwTerminate();
	return 0;
};

namespace InputCallbacks {
	 void keyboardKeyCallback(GLFWwindow *t_window, GLint t_key, GLint t_scanCode, GLint t_action, GLint t_mods) {
	 	 if(t_key == GLFW_KEY_ESCAPE && t_action == GLFW_PRESS) {
	 	 	glfwSetWindowShouldClose(SharedResoureces::window, GLFW_TRUE);
	 	 }	
	 };
	 void mouseKeyCallback(GLFWwindow *t_window, GLint t_key, GLint t_action, GLint t_mods) {
	
	 };
	 void mousePositionCallback(GLFWwindow *t_window, GLdouble t_posX, GLdouble t_posY) {
	
	 };
};// namespace InputCallbacks
