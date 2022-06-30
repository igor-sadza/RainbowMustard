#include "StateLogo.hpp"
#include "StateMenu.hpp"
#include "StateManager.hpp"

StateLogo::StateLogo() {
	StateManager::RegisterState("StateLogo", this);
};

void StateLogo::Render() {

};

void StateLogo::Logic() {

};

void StateLogo::Background() {

};

