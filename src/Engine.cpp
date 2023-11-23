//
// Created by Emiliano Barg on 22/11/2023.
//
#include "../lib/Engine.h"


const sf::Time Engine::TimePerFrame = sf::seconds(1.f/60.f);

Engine::Engine() {

    resolution = sf::Vector2f(800, 600);
    window.create(sf::VideoMode(resolution.x, resolution.y), "Snake Game", sf::Style::None);
    backgroundTexture.loadFromFile("../assets/textures/grass.png");
    backgroundSprite.setTexture(backgroundTexture);
    window.setFramerateLimit(FPS);
    maxLevels = 0;
    currentLevel = 0;
    checkLevelFiles();
    startGame();

    mainFont.loadFromFile("../assets/fonts/Cute Egg.ttf");
    setupText(&titleText, mainFont, "Snake UwU", 22, sf::Color(255, 192, 203, 255));
    sf::FloatRect titleTextBounds = titleText.getLocalBounds();
    titleText.setPosition(sf::Vector2f(resolution.x / 2 - titleTextBounds.width / 2, -5));

    setupText(&currentLevelText, mainFont, "Level: " + std::to_string(currentLevel), 22, sf::Color(255, 192, 203, 255));
    currentLevelText.setPosition(sf::Vector2f(15, -5));
    sf::FloatRect currentLevelTextBounds = currentLevelText.getGlobalBounds();

    setupText(&foodEatenThisLevelText, mainFont, "Apples Eaten: " + std::to_string(foodEatenTotal), 22, sf::Color(255, 192, 203, 255));
    foodEatenThisLevelText.setPosition(sf::Vector2f(currentLevelTextBounds.left + currentLevelTextBounds.width + 20, -5));

    setupText(&scoreText, mainFont, "Score: " + std::to_string(score), 22, sf::Color(255, 192, 203, 255));
    sf::FloatRect scoreTextBounds = scoreText.getLocalBounds();
    scoreText.setPosition(sf::Vector2f(resolution.x - scoreTextBounds.width - 15, -5));

    setupText(&gameOverText, mainFont, "Game Over", 72, sf::Color(255, 192, 203, 255));
    sf::FloatRect gameOverTextBounds = gameOverText.getLocalBounds();
    gameOverText.setPosition(sf::Vector2f(resolution.x / 2 - gameOverTextBounds.width / 2, resolution.y / 2 - gameOverTextBounds.height / 2));
    gameOverText.setOutlineColor(sf::Color::Black);
    gameOverText.setOutlineThickness(2);
    setupText(&pressRText, mainFont, "Press R to restart", 22, sf::Color(255, 192, 203, 255));
    sf::FloatRect pressRTextBounds = pressRText.getLocalBounds();
    pressRText.setPosition(sf::Vector2f(resolution.x / 2 - pressRTextBounds.width / 2, resolution.y / 2 - pressRTextBounds.height / 2 + 100));
    pressRText.setOutlineColor(sf::Color::Black);
    pressRText.setOutlineThickness(2);

    setupText(&pauseText, mainFont, "Paused", 72, sf::Color(255, 192, 203, 255));
    sf::FloatRect pauseTextBounds = pauseText.getLocalBounds();
    pauseText.setPosition(sf::Vector2f(resolution.x / 2 - pauseTextBounds.width / 2, resolution.y / 2 - pauseTextBounds.height / 2));
    pauseText.setOutlineColor(sf::Color::Black);
    pauseText.setOutlineThickness(2);
    setupText(&pressPText, mainFont, "Press P to unpause", 22, sf::Color(255, 192, 203, 255));
    sf::FloatRect pressPTextBounds = pressPText.getLocalBounds();
    pressPText.setPosition(sf::Vector2f(resolution.x / 2 - pressPTextBounds.width / 2, resolution.y / 2 - pressPTextBounds.height / 2 + 100));
    pressPText.setOutlineColor(sf::Color::Black);
    pressPText.setOutlineThickness(2);
}
//Check levels manifest files and make sure that we can open each level file
void Engine::checkLevelFiles() {
    std::ifstream levelsManifest("../assets/levels/levels.txt");
    if (!levelsManifest.is_open()) {
        std::cerr << "Error opening levels manifest file." << std::endl;
        // Handle the error, return or exit the function as needed.
        return;
    }
    std::ifstream testFile;

    for (std::string manifestLine; std::getline(levelsManifest, manifestLine);) {
        testFile.open("../assets/levels/" + manifestLine);

        if (testFile.is_open()) {
            levels.emplace_back("../assets/levels/" + manifestLine);
            testFile.close();
            maxLevels++;
        } else {
            // Handle the error, for example, log an error message.
            std::cerr << "Error opening file: " << "../assets/levels/" + manifestLine << std::endl;
            // Optionally, break the loop or take other appropriate actions.
        }
    }
}


//Load level from file and check for "X" to place walls
void Engine::loadLevel(int levelNumber) {
    std::string levelFile = levels[levelNumber - 1];
    std::ifstream level (levelFile);
    std::string line;
    if (level.is_open()) {
        for (int y = 0; y < 30; y++) {
            getline(level, line);
            for (int x = 0; x < 40; x++) {
                if (line[x] == 'x') {
                    wallSections.emplace_back(Wall(sf::Vector2f(x * 20, y * 20), sf::Vector2f(20, 20)));
                }
            }
        }
    }
    level.close();
}
void Engine::startGame() {



    score = 0;
    snakeSpeed =5;
    snakeDirection = RIGHT;
    sectionsToAdd = 0;
    timeSinceLastMove = sf::Time::Zero;
    snakeDirectionQueue.clear();
    wallSections.clear();
    foodEatenThisLevel = 0;
    foodEatenTotal = 0;
    currentLevel = 1;
    loadLevel(currentLevel);
    newSnake();
    moveFood();

    currentGameState = GameState::PLAYING;
    lastGameState = currentGameState;
    currentLevelText.setString("Level: " + std::to_string(currentLevel));
    foodEatenThisLevelText.setString("Apples Eaten: " + std::to_string(foodEatenTotal));
    scoreText.setString("Score: " + std::to_string(score));
    sf::FloatRect scoreTextBounds = scoreText.getLocalBounds();
    scoreText.setPosition(sf::Vector2f(resolution.x - scoreTextBounds.width - 15, -5));
}
/**
 * Increment level number, load next level and reset snake
 */
void Engine::beginNextLevel() {
    currentLevel++;
    wallSections.clear();
    snakeDirectionQueue.clear();
    snakeSpeed =2 +currentLevel*5;
    snakeDirection = RIGHT;
    sectionsToAdd = 0;
    foodEatenThisLevel = 0;
    timeSinceLastMove = sf::Time::Zero;
    loadLevel(currentLevel);
    newSnake();
    moveFood();
    currentLevelText.setString("Level: " + std::to_string(currentLevel));
    sf::FloatRect currentLevelTextBounds = currentLevelText.getGlobalBounds();

    foodEatenThisLevelText.setString("Apples Eaten: " + std::to_string(foodEatenTotal));
    scoreText.setString("Score: " + std::to_string(score));
    sf::FloatRect scoreTextBounds = scoreText.getLocalBounds();
    scoreText.setPosition(sf::Vector2f(resolution.x - scoreTextBounds.width - 15, -5));
}
//Initial Snake at start of level
void Engine::newSnake() {
    snake.clear();
    snake.emplace_back(sf::Vector2f(SNAKESECTION_INIT_POSX, SNAKESECTION_INIT_POSY));
    snake.emplace_back(sf::Vector2f ((SNAKESECTION_INIT_POSX + -SNAKESECTION_SIZE), SNAKESECTION_INIT_POSY));
    snake.emplace_back(sf::Vector2f ((SNAKESECTION_INIT_POSX - SNAKESECTION_SIZE*2), SNAKESECTION_INIT_POSY));

}

void Engine::addSnakeSection() {
    //Adds a section to the snake at the last position of the snake
    sf::Vector2f lastPosition = snake[snake.size()-1].getPosition();
    snake.emplace_back(lastPosition);

}

void Engine::moveFood() {
    //Find a location to place the apple
    //Must not be inside snake or walls



    //Divide the field into sections the size of the apple, remove 2 to exclude the walls
    sf::Vector2f foodResolution = sf::Vector2f (resolution.x / SNAKESECTION_SIZE - 2, resolution.y / SNAKESECTION_SIZE - 2);
    sf::Vector2f newFoodPosition;
    bool badPosition = false;
    srand(time(nullptr));
    //loop until valid location is found
    do {
        badPosition = false;
        //Generate random position
        newFoodPosition.x = (float) ( 1+ rand() / ((RAND_MAX + 1u) / (int) foodResolution.x)) * SNAKESECTION_SIZE;
        newFoodPosition.y = (float) ( 1+ rand() / ((RAND_MAX + 1u) / (int) foodResolution.y)) * SNAKESECTION_SIZE;
        //Check if position is inside snake
        for (auto &section : snake) {
            if (section.getPosition() == newFoodPosition) {
                badPosition = true;
            }
        }
        //Add check for walls
        for (auto &wall : wallSections) {
            if (wall.getShape().getGlobalBounds().intersects(sf::Rect<float>(newFoodPosition.x, newFoodPosition.y, SNAKESECTION_SIZE, SNAKESECTION_SIZE))) {
                badPosition = true;
                break;
            }
        }
    } while (badPosition);
    food.setPosition(newFoodPosition);
    }




void Engine::togglePause() {
    if (currentGameState == GameState::PLAYING) {
        lastGameState = currentGameState;
        currentGameState = GameState::PAUSED;
    } else if (currentGameState == GameState::PAUSED) {
        currentGameState = lastGameState;
    }
}

void Engine::setupText(sf::Text *textItem, sf::Font &font, const std::string &value, int size, sf::Color color) {
    textItem->setFont(font);
    textItem->setString(value);
    textItem->setCharacterSize(size);
    textItem->setFillColor(color);
}

void Engine::run() {
    sf::Clock clock;

    while (window.isOpen()){
        sf::Time deltaTime = clock.restart();
        if (currentGameState == GameState::PAUSED || currentGameState == GameState::GAMEOVER) {
            //If paused check for input to unpause
            input();

            if (currentGameState == GameState::GAMEOVER) {
                draw();
            }
            sleep(sf::milliseconds(2));
            continue;
        }

        timeSinceLastMove += deltaTime;   //adds delta time to time since last move
        input();
        update();
        draw();

    }
}
