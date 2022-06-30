#ifndef PIECES_MANAGER_HPP 
#define PIECES_MANAGER_HPP 

#include "CommonIncludes.hpp"

template<class Type>
class PiecesManager{
	private:
		static std::vector<Type> m_registry;
		static bool search(Type t_object);
	public:
		static void registerObject(Type t_object);
		static Type getObject(const std::string& t_objectName);
	
};

#include "PiecesManager.hxx"

#endif //PIECES_MANAGER_HPP 
