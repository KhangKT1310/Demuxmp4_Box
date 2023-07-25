cmake_minimum_required(VERSION 3.14)

# set(CMAKE_C_COMPILER asdk-linux-gcc)
# set(CMAKE_CXX_COMPILER asdk-linux-g++)
set(DIR_SRC ${CMAKE_SOURCE_DIR}/src)

project(mp4)
add_compile_options(-Wno-psabi)

set(CMAKE_CXX_STANDARD 14)

FILE(GLOB_RECURSE sources src/*.c )
include_directories(include)

add_executable(mp4demuxer ${sources})


