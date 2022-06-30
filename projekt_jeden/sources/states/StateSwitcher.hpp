#ifndef STATE_SWITCHER_HPP
#define STATE_SWITCHER_HPP

class StateSwitcher {
	private:
		StateSwitcher();	
	public:
		static StateSwitcher &initSwitcher();
		static void seletecStateLogic();
		static void selectedStateBackground(); 
		static void selectedStateRender();

}; // class StateSwitcher 

#endif // STATE_SWITCHER_HPP
