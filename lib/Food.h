//
// Created by Emiliano Barg on 22/11/2023.
//

#ifndef SNAKE_GAME_FOOD_H
#define SNAKE_GAME_FOOD_H
#define FOOD_SIZE 20
#define FOOD_INIT_POSX 200
#define FOOD_INIT_POSY 400
#include <SFML/Graphics.hpp>


class Food {
private:
    sf::RectangleShape sprite;
    sf::Texture texture;
    sf::Vector2f position;

public:
    Food();
    void setPosition(sf::Vector2f newPosition);
    sf::RectangleShape getSprite();

};


#endif //SNAKE_GAME_FOOD_H
