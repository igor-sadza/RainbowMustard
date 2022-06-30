#ifndef STATE_HPP
#define STATE_HPP

class State {
	public:
		virtual void Render() = 0;
		virtual void Logic() = 0;
		virtual void Background() = 0;
};

#endif // STATE_HPP
