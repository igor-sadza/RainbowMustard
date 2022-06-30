#include "CommonIncludes.hpp"
#include "CommonIncludes.hpp"
#include "SharedResources.hpp"
#include "Settings.hpp"
#include "StateSwitcher.hpp"
// -----------------
#include "Shader.hpp"
#include "PrimitiveRenderer.hpp"
#include "Primitive.hpp"
#include "FileParser.hpp"

#include <unistd.h>
#include <sys/types.h>
#include <dirent.h>
#include <stdio.h>
#include <string.h>

// -----------------
namespace InputCallbacks {
	void keyboardKeyCallback(GLFWwindow *t_window, GLint t_key, GLint t_scanCode, GLint t_action, GLint t_mods);
	void mouseKeyCallback(GLFWwindow *t_window, GLint t_key, GLint t_action, GLint t_mods);
	void mousePositionCallback(GLFWwindow *t_window, GLdouble t_posX, GLdouble t_posY);
}; // namespace InputCallbacks

std::fstream fileSearch(const std::string &t_fileName) {
	struct dirent *entry;
	int ite = 0;
	std::vector<std::string> dirNames = {"."};
	DIR *dir = opendir(dirNames[ite].c_str());

	std::fstream file;
	std::string filePath;
	while(dir) {
		while((entry = readdir(dir))) {
			if(entry->d_type == DT_DIR) {
				if(!strcmp(entry->d_name, ".") || !strcmp(entry->d_name, "..")) { 
					continue;
				};
				std::string newFolderPath = dirNames[ite] + '/' + entry->d_name;
				dirNames.push_back(newFolderPath);
			} else
			if(entry->d_type == DT_REG) {
				if(!strcmp(entry->d_name, t_fileName.c_str())) {
					filePath = dirNames[ite] + '/' + entry->d_name;
				};
			};
		};
		dir = opendir(dirNames[++ite].c_str());
	};
	try { 
		file.open(filePath.c_str());
		if(!file) throw std::ios::failure("Error opening file\n");

	} catch(std::exception const &e) {
		std::cout << e.what() << std::endl;
	};

	return file;
}

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

	//StateSwitcher::initSwitcher();

	Shader sh("test.sh");
	Primitive pr;

	pr.SetPrimitiveColor(1.0f, 0.0f, 0.0f, 1.0f);
	pr.SetPrimitivePosition(10.0f);
	pr.SetPrimitiveSize(30.0f);

	PrimitiveRenderer::initRenderer();
	//Game loop
	while(!glfwWindowShouldClose(SharedResoureces::window)) {
		glfwPollEvents();	

		glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
		glClear(GL_COLOR_BUFFER_BIT);
		

	        glm::mat4 modelMatrix;        
	        modelMatrix = glm::translate(modelMatrix, glm::vec3(100.0f, 100.0f, 0.0f));
	        modelMatrix = glm::scale(modelMatrix, glm::vec3(100.0f, 100.0f, 0.0f));
	        
	        sh.SendVariable("t_model", modelMatrix);
	        sh.SendVariable("t_color", pr.GetPrimitiveColor());        
	        PrimitiveRenderer::renderPrimitive();  

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
