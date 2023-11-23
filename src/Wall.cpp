//
// Created by Emiliano Barg on 22/11/2023.
//

#include "../lib/Wall.h"
Wall::Wall(sf::Vector2f position, sf::Vector2f size) {
    wallShape.setSize(size);
    wallShape.setFillColor(sf::Color::Black);
    wallShape.setPosition(position);

}

sf::RectangleShape Wall::getShape() {
    return wallShape;
}