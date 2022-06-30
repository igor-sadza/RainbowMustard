#include "StateSwitcher.hpp"
#include "StateManager.hpp"
#include "StateLogo.hpp"
#include "StateMenu.hpp"

StateSwitcher::StateSwitcher() {
	StateLogo *stateLogo = new StateLogo();
	StateMenu *stateMenu = new StateMenu();

	StateManager::SetInstance("StateLogo");
};

StateSwitcher &StateSwitcher::initSwitcher() {
	static StateSwitcher stateSwitcher;
	return stateSwitcher;
};

void StateSwitcher::seletecStateLogic() {
	StateManager::GetInstance()->Logic();
};

void StateSwitcher::selectedStateBackground() {
	StateManager::GetInstance()->Background();
};

void StateSwitcher::selectedStateRender() {
	StateManager::GetInstance()->Render();
};
