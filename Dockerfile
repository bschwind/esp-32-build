FROM ubuntu:14.04

# Install build dependencies (and vim + picocom for editing/debugging)
RUN apt-get -qq update \
    && apt-get install -y git wget make libncurses-dev flex bison gperf python python-serial vim picocom \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create some directories
RUN mkdir -p /esp
RUN mkdir /esp/esp-idf
RUN mkdir /esp/project

# Get the ESP32 toolchain and extract it to /esp/xtensa-esp32-elf
RUN wget -O /esp/esp-32-toolchain.tar.gz https://dl.espressif.com/dl/xtensa-esp32-elf-linux64-1.22.0-61-gab8375a-5.2.0.tar.gz \
    && tar -xzf /esp/esp-32-toolchain.tar.gz -C /esp \
    && rm /esp/esp-32-toolchain.tar.gz

# Add the toolchain binaries to PATH
ENV PATH /esp/xtensa-esp32-elf/bin:$PATH

# Setup IDF_PATH
ENV IDF_PATH /esp/esp-idf

# This is the directory where our project will show up
WORKDIR /esp/project
