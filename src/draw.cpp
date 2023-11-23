//
// Created by Emiliano Barg on 22/11/2023.
//
#include "../lib/Engine.h"

void Engine::draw() {
    window.clear(sf::Color::Black);
    window.draw(backgroundSprite);
    //draw walls
    for (auto &wall : wallSections) {
        window.draw(wall.getShape());
    }
    //draw title
    window.draw(titleText);
    window.draw(currentLevelText);
    window.draw(foodEatenThisLevelText);
    window.draw(scoreText);


    //draw food
    window.draw(food.getSprite());


    //draw snake
    for (auto &section : snake) {
        window.draw(section.getShape());
    }
    if(currentGameState == GameState::GAMEOVER){
        window.draw(gameOverText);
        window.draw(pressRText);
    }
    if (currentGameState == GameState::PAUSED){
        window.draw(pauseText);
        window.draw(pressPText);
    }
    window.display();
}