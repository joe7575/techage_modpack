cmake_minimum_required(VERSION 3.0.0)
project(tinybasic VERSION 0.1.0 LANGUAGES C)

include_directories(./src)
add_compile_options(-Wall)

add_executable(nanobasic
    ./src/nb_scanner.c
    ./src/nb_compiler.c
    ./src/nb_runtime.c
    ./src/nb_memory.c
    ./test/main.c
    ./src/nb.h
    ./src/nb_int.h
)

set(CPACK_PROJECT_NAME ${PROJECT_NAME})
set(CPACK_PROJECT_VERSION ${PROJECT_VERSION})
