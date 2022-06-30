#ifndef STATE_MANAGER_HPP
#define STATE_MANAGER_HPP

#include "CommonIncludes.hpp"
#include "State.hpp"

class StateManager {
	private:
		typedef std::map<std::string, State *> StateRegister;
		static StateRegister m_registry;
		static State *m_currentState;

		static State *LookUp(const std::string &t_stateName);
	public:
		static State *GetInstance();
		static void SetInstance(const std::string &t_stateName);
		static void RegisterState(const std::string &t_stateName, State *t_state);
};

#endif // STATE_MANAGER_HPP
