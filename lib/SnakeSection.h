//
// Created by Emiliano Barg on 22/11/2023.
//

#ifndef SNAKE_GAME_SNAKESECTION_H
#define SNAKE_GAME_SNAKESECTION_H
#define SNAKESECTION_SIZE 20
#define SNAKESECTION_INIT_POSX 100
#define SNAKESECTION_INIT_POSY 100
#include <SFML/Graphics.hpp>



class SnakeSection {
    private:
    sf::Vector2f position;
    sf::RectangleShape headSection;

    public:
    SnakeSection(sf::Vector2f startPosition);
    sf::Vector2f getPosition();
    void setPosition(sf::Vector2f newPosition);
    sf::RectangleShape getShape();
    void update();
};


#endif //SNAKE_GAME_SNAKESECTION_H
