# CMakeList.txt : CMake project for ElefantBlaster.
# Include source and define project specific logic here.
#
cmake_minimum_required (VERSION 3.20)

# C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(PROJECT_NAME "ElefantBlaster")
project (${PROJECT_NAME} LANGUAGES C CXX)

# Enable ccache if available
find_program(CCACHE_PROGRAM ccache)
set(CMAKE_CXX_COMPILER_LAUNCHER ccache)

# ========================================
# Testing Configuration
# ========================================
option(BUILD_TESTING "Build tests for the project and libraries" ON)

if(BUILD_TESTING)
    enable_testing()
endif()

include(FetchContent)

if(NOT EMSCRIPTEN)
    # OpenSSL
    find_package(OpenSSL REQUIRED)

    # asio (Asynchronous I/O library)
    FetchContent_Declare(
        asio
        SOURCE_DIR ${CMAKE_SOURCE_DIR}/libs/asio/asio
    )
    FetchContent_MakeAvailable(asio)

    # websocketpp (C++ WebSocket library)
    FetchContent_Declare(
        websocketpp
        SOURCE_DIR ${CMAKE_SOURCE_DIR}/libs/websocketpp
    )
    FetchContent_GetProperties(websocketpp)
    if(NOT websocketpp_POPULATED)
        FetchContent_Populate(websocketpp)
    endif()
    # Create an interface target for websocketpp
    add_library(websocketpp_interface INTERFACE)
    target_include_directories(websocketpp_interface INTERFACE
        ${websocketpp_SOURCE_DIR}
        ${asio_SOURCE_DIR}/include
    )
    # Define ASIO_STANDALONE for websocketpp to use standalone Asio
    target_compile_definitions(websocketpp_interface INTERFACE
        ASIO_STANDALONE
        ASIO_ENABLE_OLD_SERVICES
        _WEBSOCKETPP_CPP11_STL_
        WEBSOCKETPP_SSL_BACKEND_OPENSSL
    )
    # Link OpenSSL libraries
    target_link_libraries(websocketpp_interface INTERFACE OpenSSL::SSL OpenSSL::Crypto)
    # Create an alias for easier usage
    add_library(websocketpp::websocketpp ALIAS websocketpp_interface)
endif()

# Include sub-projects.
add_subdirectory("ElefantBlasterCommon")

add_subdirectory("ElefantBlasterClient")

if(NOT EMSCRIPTEN AND NOT ANDROID)
    add_subdirectory("ElefantBlasterServer")
    add_subdirectory("ElefantBlasterServerInterface")
endif()
