# ElefantBlaster

# Prequisite:
Windows:
    install vcpkg
    set env: VCPKG_PATH

# Build websocketpp
#   openssl:x64-windows@3.5.0#1
    vcpkg install openssl:x64-windows

# Linux dev
    sudo apt update
    sudo apt-get install \
        build-essential \
        cmake \
        ninja-build \
        git \
        libssl-dev \
        pkg-config \
        libwayland-dev \
        libxkbcommon-dev \
        libegl1-mesa-dev \
        libpipewire-0.3-dev \
        libdecor-0-dev \
        libudev-dev \
        liburing-dev \
        libunwind-dev \
        libusb-1.0-0-dev
