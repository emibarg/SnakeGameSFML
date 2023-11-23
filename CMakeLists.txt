cmake_minimum_required(VERSION 3.16)
project(SNAKE_GAME LANGUAGES CXX)


set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
option(BUILD_SHARED_LIBS "Build shared libraries" OFF)

include(FetchContent)
FetchContent_Declare(SFML
        GIT_REPOSITORY https://github.com/SFML/SFML.git
        GIT_TAG 2.6.x)
FetchContent_MakeAvailable(SFML)

add_executable(SNAKE_GAME src/main.cpp
        src/Engine.cpp
        src/draw.cpp
        src/input.cpp
        src/input.cpp
        src/SnakeSection.cpp
        src/update.cpp
        src/Food.cpp
        src/Wall.cpp)
target_link_libraries(SNAKE_GAME PRIVATE sfml-graphics)
target_compile_features(SNAKE_GAME PRIVATE cxx_std_17)

if(WIN32)
    add_custom_command(
            TARGET SNAKE_GAME
            COMMENT "Copy OpenAL DLL"
            PRE_BUILD COMMAND ${CMAKE_COMMAND} -E copy ${SFML_SOURCE_DIR}/extlibs/bin/$<IF:$<EQUAL:${CMAKE_SIZEOF_VOID_P},8>,x64,x86>/openal32.dll $<TARGET_FILE_DIR:SNAKE_GAME>
            VERBATIM)
endif()
install(DIRECTORY assets DESTINATION .)
install(TARGETS SNAKE_GAME)
if(WIN32)
    set(CPACK_GENERATOR NSIS)  # Use NSIS (Nullsoft Scriptable Install System) for Windows
endif()

include(CPack)
