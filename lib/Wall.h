//
// Created by Emiliano Barg on 22/11/2023.
//

#ifndef SNAKE_GAME_WALL_H
#define SNAKE_GAME_WALL_H
#include <SFML/Graphics.hpp>

class Wall {
private:
    sf::RectangleShape wallShape;
public:
    Wall(sf::Vector2f position, sf::Vector2f size);
    sf::RectangleShape getShape();
};


#endif //SNAKE_GAME_WALL_H
