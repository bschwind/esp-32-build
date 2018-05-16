esp-32 Build Environment
===============================

[![Docker Pulls](https://img.shields.io/docker/pulls/bschwind/esp-32-build.svg)](https://hub.docker.com/r/bschwind/esp-32-build/) [![Docker Stars](https://img.shields.io/docker/stars/bschwind/esp-32-build.svg)](https://hub.docker.com/r/bschwind/esp-32-build/) [![](https://images.microbadger.com/badges/image/bschwind/esp-32-build.svg)](https://microbadger.com/images/bschwind/esp-32-build "Get your own image badge on microbadger.com") [![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://github.com/bschwind/esp-32-build/blob/master/LICENSE)

This Dockerfile contains the dependencies necessary to build and flash programs for the ESP32 chip.

Dependencies
------------
- [Docker](https://www.docker.com/products/docker-toolbox)
- [Virtualbox](https://www.virtualbox.org/wiki/Downloads) (if you're not on Linux)

Quick Setup
-----------

* `docker pull bschwind/esp-32-build`
* `cd` to your esp-32 project
* Without USB flashing support: `docker run --rm -it -v $(PATH_TO_ESP_IDF):/esp/esp-idf -v $(PATH_TO_YOUR_PROJECT):/esp/project bschwind/esp-32-build /bin/bash`
* With USB flashing support: `docker run --rm -it --privileged -v /dev/bus/usb:/dev/bus/usb -v $(PATH_TO_ESP_IDF):/esp/esp-idf -v $(PATH_TO_YOUR_PROJECT):/esp/project bschwind/esp-32-build /bin/bash`

Either step will put you in an interactive shell inside the container. If you have a Makefile in your project directory, you can immediately
run `make` and your source should get compiled. `make flash` will attempt to flash the code to `/dev/ttyUSB0`.

Flashing Images from the Container
----------------------------------

If you're on docker-machine (OS X or Windows), you need to forward your USB device within Virtualbox. This is best managed in the VirtualBox GUI.

Steps:

* Stop your docker virtual machine host, if applicable
* Plug in the USB serial device you will use to flash to the ESP8266
* Install [virtualbox extensions](https://www.virtualbox.org/wiki/Downloads) to support USB (Ctrl-F "extension" on that page)
  * OS X -> Under "Virtualbox" -> Preferences, go to the Extensions tab
  * Windows -> Same thing?
  * Click the "Adds new package" button and select the extension pack you downloaded
* Return to the main VirtualBox GUI
* Right click on your docker VM and select "Settings"
* Select "Ports" -> "USB"
* Check the box "Enable USB Controller" and select "USB 2.0 (EHCI) Controller"
* Under "USB Device Filters" click the USB icon with the green plus sign to add a USB device
* Select your USB serial device (in my case it was "FTDI FT232R USB UART [0600]")
* Click OK until you're back to the main Virtualbox GUI
* At this point you can restart your virtual machine with `docker-machine start <YOUR_DOCKER_VM_NAME>`
* Run docker as we did in Quick Setup: `docker run --rm -it --privileged -v /dev/bus/usb:/dev/bus/usb -v $(PWD):/esp/project bschwind/esp-32-build /bin/bash`
  * NOTE: With the `-v /dev/bus/usb:/dev/bus/usb` volume, the `/dev/bus/usb` on the lefthand side of the colon refers to docker VM's USB directory, *not* your host machine (you likely won't find that path on OS X)
* `/dev/ttyUSB0` should now be available
* Run `make` and then `make flash` on an example project or your own

If you're on Linux, it should be sufficient to share your USB device either as a docker volume or with the `--device` flag. However, I have not yet tested Linux.

Serial Debugging
----------------

[Picocom](https://github.com/npat-efault/picocom) is installed in this image by default. Invoke it with `picocom -b 115200 /dev/ttyUSB0` (change the baud rate and device path accordingly)

Stop it with `Ctrl-A Ctrl-X`

PRO TIP
-------

You can change the baud rate and other properties with `make menuconfig` which will drop you in esp-idf's project configuration menu. I recommend selecting a baud rate of 921600 as it will reduce flashing times to around 4-5 seconds.

Using ccache
--------------

* `docker pull bschwind/esp-32-build`
* `cd` to your esp-32 project
* create the ccache persistent directory
  `docker create -v /mnt/ccache:/ccache --name ccache bschwind/esp-32-build`
* `docker run --rm -it -v $(PATH_TO_ESP_IDF):/esp/esp-idf -v $(PATH_TO_YOUR_PROJECT):/esp/project -e CCACHE_DIR=/ccache --volumes-from ccache bschwind/esp-32-build /bin/bash`

