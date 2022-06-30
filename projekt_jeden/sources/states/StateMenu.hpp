#ifndef STATE_MENU_HPP
#define STATE_MENU_HPP

#include "State.hpp"

class StateMenu : public State {
	private:
	public:
		StateMenu();
		void Render();
		void Logic();
		void Background();
};

#endif //STATE_MENU_HPP
