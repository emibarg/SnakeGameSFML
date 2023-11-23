//
// Created by Emiliano Barg on 22/11/2023.
//
#include "../lib/Engine.h"

void Engine::update() {
    //update snake
    if (timeSinceLastMove.asSeconds() >= sf::seconds(1.f / float(snakeSpeed)).asSeconds()) {
        sf::Vector2f thisSectionPosition = snake[0].getPosition();
        sf::Vector2f lastSectionPosition = thisSectionPosition;
    //Is there anything in snakeDirectionQueue
    if (!snakeDirectionQueue.empty()){
        //Make sure snake is not going in the opposite direction
        switch (snakeDirection) {
            case Direction::UP:
                if (snakeDirectionQueue.front() != Direction::DOWN) {
                    snakeDirection = snakeDirectionQueue.front();
                }
                break;
            case Direction::DOWN:
                if (snakeDirectionQueue.front() != Direction::UP) {
                    snakeDirection = snakeDirectionQueue.front();
                }
                break;
            case Direction::LEFT:
                if (snakeDirectionQueue.front() != Direction::RIGHT) {
                    snakeDirection = snakeDirectionQueue.front();
                }
                break;
            case Direction::RIGHT:
                if (snakeDirectionQueue.front() != Direction::LEFT) {
                    snakeDirection = snakeDirectionQueue.front();
                }
                break;
        }
        snakeDirectionQueue.pop_front();
    }
    //Grow snake if needed
    if (sectionsToAdd){
        addSnakeSection();
        sectionsToAdd--;
    }
    //Update head position
    switch (snakeDirection) {
        case Direction::UP:
            snake[0].setPosition(sf::Vector2f(thisSectionPosition.x, thisSectionPosition.y - SNAKESECTION_SIZE));
            break;
        case Direction::DOWN:
            snake[0].setPosition(sf::Vector2f(thisSectionPosition.x, thisSectionPosition.y + SNAKESECTION_SIZE));
            break;
        case Direction::LEFT:
            snake[0].setPosition(sf::Vector2f(thisSectionPosition.x - SNAKESECTION_SIZE, thisSectionPosition.y));
            break;
        case Direction::RIGHT:
            snake[0].setPosition(sf::Vector2f(thisSectionPosition.x + SNAKESECTION_SIZE, thisSectionPosition.y));
            break;
    }
    //Update score
        score += snake.size() + 3*foodEatenThisLevel;
        scoreText.setString("Score: " + std::to_string(score));
        sf::FloatRect scoreTextBounds = scoreText.getLocalBounds();
        scoreText.setPosition(sf::Vector2f(resolution.x - scoreTextBounds.width - 15, -5));
    //Update rest of snake
    for (int i = 1; i < snake.size(); i++) {
        thisSectionPosition = snake[i].getPosition();
        snake[i].setPosition(lastSectionPosition);
        lastSectionPosition = thisSectionPosition;
    }
    //run snakesection update function
    for (auto &i : snake) {
        i.update();
    }
    //Check if snake has eaten food
    if (snake[0].getShape().getGlobalBounds().intersects(food.getSprite().getGlobalBounds())) {


        // increase snake speed


        //Add a section to the snake
        foodEatenThisLevel++;
        foodEatenTotal++;
        foodEatenThisLevelText.setString("Apples Eaten: " + std::to_string(foodEatenTotal));
        //check if time for next level
        bool beginningNextLevel = false;
        if (foodEatenThisLevel >5) {
            //begin next level, if all levels completed stay on level and get harder
            if (currentLevel < maxLevels) {
                beginningNextLevel = true;
                beginNextLevel();
            }
        }
        //Add 4 sections to the snake
        if (!beginningNextLevel){snakeSpeed += 2;
        sectionsToAdd += 4;
        moveFood();}
    }

    //Snake body collision
    for (int i = 1; i < snake.size(); i++) {
        if (snake[0].getShape().getGlobalBounds().intersects(snake[i].getShape().getGlobalBounds())) {
            //TODO - Game over
            currentGameState = GameState::GAMEOVER;
        }
    }
    //Snake wall collision
    for (auto &wall : wallSections) {
        if (snake[0].getShape().getGlobalBounds().intersects(wall.getShape().getGlobalBounds())) {
            //TODO - Game over
            currentGameState = GameState::GAMEOVER;
        }
    }
    //Reset timeSinceLastMove
    timeSinceLastMove = sf::Time::Zero;
    } // END update snakeposition

}