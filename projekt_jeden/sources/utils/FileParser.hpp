#ifndef FILE_PARSER_HPP
#define FILE_PARSER_HPP

#include "CommonIncludes.hpp"

class FileParser {
	private:
		typedef std::vector<std::string> StringVector;
		typedef std::pair<std::string, std::string> StringPair;

		std::vector<StringPair> m_sources;	
		std::map<std::string, std::map<std::string, std::string>> m_sourceVariables;

		std::fstream findFile(const std::string &t_fileName);
		void parseToSources(std::fstream &t_fileStream);
		void parseToVariables();
	public:
		FileParser(const std::string &t_fileName);

		std::string getSource(const std::string &t_sourceName);
		std::string getVariable(const std::string &t_sourceName, const std::string &t_variableName);
};
#endif //FILE_PARSER_HPP
