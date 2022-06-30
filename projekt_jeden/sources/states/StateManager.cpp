#include "StateManager.hpp"

StateManager::StateRegister StateManager::m_registry;
State *StateManager::m_currentState;

State *StateManager::LookUp(const std::string &t_stateName) {
	for(auto& ite: m_registry) {
		if (ite.first == t_stateName) {
			return ite.second;
		};
	};

	std::cout << "The state you were looking for was not found\n";
	return nullptr;
};

State *StateManager::GetInstance() {
	return m_currentState;
};

void StateManager::SetInstance(const std::string &t_stateName) {
	m_currentState = LookUp(t_stateName);
};

void StateManager::RegisterState(const std::string &t_stateName, State *t_state) {
	m_registry.insert(StateRegister::value_type(t_stateName, t_state));
	m_currentState = t_state;
};
