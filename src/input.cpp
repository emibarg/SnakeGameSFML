//
// Created by Emiliano Barg on 22/11/2023.
//
#include "../lib/Engine.h"

void Engine::input() {
    sf::Event event;
    while (window.pollEvent(event)){
        if (event.type == sf::Event::Closed){
            window.close();
        }
     //handle keyboard input
        if (event.type == sf::Event::KeyPressed){
            //quit
            if (event.key.code == sf::Keyboard::Escape){
                window.close();
            }
            //pause
            else if (event.key.code == sf::Keyboard::P){
                togglePause();
            }
            //restart
            if (currentGameState == GameState::GAMEOVER){
                if (event.key.code == sf::Keyboard::R){
                    startGame();
                }
            }
            //move up
            if (event.key.code == sf::Keyboard::Up){
                addDirection(Direction::UP);
            }
            //move down
            else if (event.key.code == sf::Keyboard::Down){
                addDirection(Direction::DOWN);
            }
            //move left
            else if (event.key.code == sf::Keyboard::Left){
                addDirection(Direction::LEFT);
            }
            //move right
            else if (event.key.code == sf::Keyboard::Right){
                addDirection(Direction::RIGHT);
            }

        }
    }
}
void Engine::addDirection(int newDirection) {
    if (snakeDirectionQueue.empty()){
        snakeDirectionQueue.emplace_back(newDirection);
    }
    else if (snakeDirectionQueue.back() != newDirection){
        snakeDirectionQueue.emplace_back(newDirection);
    }

}
