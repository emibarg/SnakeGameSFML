//
// Created by Emiliano Barg on 22/11/2023.
//

#include "../lib/SnakeSection.h"
SnakeSection::SnakeSection(sf::Vector2f startPosition) {
    headSection.setSize(sf::Vector2f(SNAKESECTION_SIZE, SNAKESECTION_SIZE));
    headSection.setFillColor(sf::Color (255, 192, 203, 255));
    headSection.setPosition(startPosition);
    position = startPosition;

}

sf::Vector2f SnakeSection::getPosition() {
    return headSection.getPosition();
}

void SnakeSection::setPosition(sf::Vector2f newPosition) {
    position = newPosition;
}

sf::RectangleShape SnakeSection::getShape() {
    return headSection;
}

void SnakeSection::update() {
    headSection.setPosition(position);
}