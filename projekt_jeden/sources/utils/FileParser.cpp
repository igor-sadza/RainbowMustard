#include "FileParser.hpp"

#include <unistd.h>
#include <sys/types.h>
#include <dirent.h>
#include <stdio.h>

//Public functions
FileParser::FileParser(const std::string &t_fileName) {

	try {
		std::fstream fileStream;
		fileStream = findFile(t_fileName);
		if(!fileStream)  {
			throw std::ios::failure("Error opening file: " + t_fileName + " \n");
		}; 

		parseToSources(fileStream);
		parseToVariables();

	} catch(std::exception const &e) {
		std::cout << e.what() << std::endl;
		exit (EXIT_FAILURE);
	};

};
std::string FileParser::getSource(const std::string &t_sourceName) {
	for(auto& sources: m_sources) {
		if(t_sourceName == sources.first) {
			return sources.second;
		};
	};
	return std::string();
};
std::string FileParser::getVariable(const std::string &t_sourceName, const std::string &t_variableName) {
	for(auto source: m_sourceVariables) {
		if(source.first == t_sourceName) {
			for(auto variable: source.second) {
				if(variable.first == t_variableName) {
					return variable.second;
				};	
			};
		};
	};
	return std::string();
};
//Private functions
std::fstream FileParser::findFile(const std::string &t_fileName) {
	struct dirent *entry;
	DIR *dir;	
	int ite = 0;
	std::vector<std::string> dirNames = {"."};
	std::string filePath;
	while((dir = opendir(dirNames[ite].c_str()))) {
		while((entry = readdir(dir))) {
			if(entry->d_type == DT_DIR) {
				if(!strcmp(entry->d_name, ".") || !strcmp(entry->d_name, "..")) { 
					continue;
				};
				std::string newFolderPath = dirNames[ite] + '/' + entry->d_name;
				dirNames.push_back(newFolderPath);
			} 
			else
			if(entry->d_type == DT_REG) {
				if(!strcmp(entry->d_name, t_fileName.c_str())) {
					filePath = dirNames[ite] + '/' + entry->d_name;
				};
			};
		};
		if(ite++ == dirNames.size()-1) {
			break;
		};
	};

	std::fstream file;
	file.open(filePath.c_str());
	return file;
};
void FileParser::parseToSources(std::fstream &t_fileStream) {
	std::string line;
	StringPair source;
	while(std::getline(t_fileStream, line)) {

		if(line.length() == 0 || !line.find("//")) {
			continue;
		};

		if(line.at(0) == '[') {
			if(source.second.length() > 0) {
				m_sources.push_back(source);
				source = StringPair();
			};

			source.first = line.substr(1, line.size()-2);
			continue;	
		};
		source.second += line + '\n';
	};

	if(source.second.length() > 0) {
		m_sources.push_back(source);
	};
};
void FileParser::parseToVariables() {
	for(auto&source_ite: m_sources) {
		std::istringstream stringStream;
		stringStream.str(source_ite.second);
	
		std::vector<StringPair> variables;
		std::string line;
	
		std::map<std::string, std::string> t_mapVar;
	
		while(getline(stringStream, line)) {
	
			std::size_t singPos = line.find_first_of(' '); 
			while(singPos != std::string::npos) {
				line.erase(line.begin()+singPos);
				singPos = line.find_first_of(' ');
			};
	
			std::string variableName;
			std::string variableValue;
	
			std::vector<std::string> t_var;
	
			StringPair variable;
	
			singPos = line.find_first_of('='); 
			if(singPos != std::string::npos) {
				variableName = line.substr(0, singPos);
				line.erase(0, singPos+1);
				variable.first = variableName;
			};
			variableValue += line;
			t_mapVar[variableName] = variableValue;
		};
		m_sourceVariables[source_ite.first] = t_mapVar;
	};
};
