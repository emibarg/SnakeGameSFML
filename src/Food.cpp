//
// Created by Emiliano Barg on 22/11/2023.
//

#include "../lib/Food.h"
Food::Food() {
    texture.loadFromFile("../assets/textures/manzanita.png");
    sf::Vector2f startingPosition(FOOD_INIT_POSX, FOOD_INIT_POSY);
    sprite.setSize(sf::Vector2f(FOOD_SIZE, FOOD_SIZE));
    sprite.setTexture(&texture);
    sprite.setPosition(startingPosition);
    position = startingPosition;

}

void Food::setPosition(sf::Vector2f newPosition) {
    sprite.setPosition(newPosition);
}

sf::RectangleShape Food::getSprite() { return sprite; }
