//
// Created by Emiliano Barg on 22/11/2023.
//

#ifndef SNAKE_GAME_ENGINE_H
#define SNAKE_GAME_ENGINE_H

#include "SnakeSection.h"
#include "Food.h"
#include "Wall.h"

#include <SFML/Graphics.hpp>
#include <SFML/Graphics/RectangleShape.hpp>
#include <vector>
#include <deque>
#include <fstream>
#include <iostream>
class Engine {
private:
    //Window
    sf::Vector2f resolution;
    sf::RenderWindow window;
    sf::Texture backgroundTexture;
    sf::Sprite backgroundSprite;
    const unsigned int FPS = 60;
    static const sf::Time TimePerFrame;
    //Snake
    std::vector<SnakeSection> snake;
    int snakeDirection;
    int snakeSpeed;
    int sectionsToAdd; //Number of sections to add to the snake
    sf::Time timeSinceLastMove;
    std::deque<int> snakeDirectionQueue; //Queue of directions to be executed
    //Food
    Food food;
    int foodEatenThisLevel;
    int foodEatenTotal;
    unsigned long long int score;
    //Walls
    std::vector<Wall> wallSections;
    int currentLevel;
    int maxLevels;
    std::vector<std::string> levels;
    //font
    sf::Font mainFont;
    sf::Text titleText;
    sf::Text foodEatenThisLevelText;
    sf::Text currentLevelText;
    sf::Text scoreText;
    sf::Text gameOverText;
    sf::Text pressRText;
    sf::Text pauseText;
    sf::Text pressPText;

    //GAMESTATE
    int currentGameState;
    int lastGameState; //stores the last game state before pause


public:
    enum GameState {PLAYING, PAUSED, GAMEOVER};
    enum Direction {UP, DOWN, LEFT, RIGHT};
    Engine();
    void input();
    void addDirection(int newDirection);
    void update();
    void draw();

    static void setupText(sf::Text *textItem, sf::Font &font, const std::string &value, int size, sf::Color color);

    void newSnake();
    void addSnakeSection();

    void moveFood();
    void checkLevelFiles();
    void loadLevel(int levelNumber);
    void togglePause();
    void beginNextLevel();
    void startGame();
    //Game loop
    void run();
};
#endif //SNAKE_GAME_ENGINE_H
