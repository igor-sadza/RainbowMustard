#ifndef STATE_LOGO_HPP
#define STATE_LOGO_HPP

#include "CommonIncludes.hpp"
#include "State.hpp"

class StateLogo : public State {
	private:
	public:
		StateLogo();
		void Render();
		void Logic();
		void Background();
};

#endif //STATE_LOGO_HPP
