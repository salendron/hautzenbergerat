---
title: "How to develop on a RaspberryPi Pico using Micropython"
date: 2021-02-01T15:25:12Z
draft: true
---
A few days ago I got two brand new RaspberryPi Pico Boards and so it is time to build something using this new toy. So let's talk about what it actually is, how to setup a MicroPython development environment and also build a simple example project to make sure everything works as expected.

## This one is not like the others
I won't go to much into the specs of this board, since you can read them for your self [here](https://www.raspberrypi.org/products/raspberry-pi-pico/), instead I will focus here on two specific things that set's this Pi appart from others like it.
First this is a RaspberryPi, but it is no single board computer, running a Linux OS, like other RaspberryPis, it is a microcontroller. So we better compare it to an Arduino or an ESP32. If we compare it to an Arduino, we'll notice various technical differences, but we also see that we  can not only program the RaspberryPi Pico using C/C++, like Arduinos, but also using MicroPython and that's exactly what we'll do in this article.

## Setup
First we have to make sure that the Pico is able to run MicroPython. To do so we need to download the MicroPython UF2 file from the [RaspberryPi Pico website](https://www.raspberrypi.org/documentation/pico/getting-started/).
Now we can take our Pico and push and hold the BOOTSEL button (the big white one on the board) while connecting the Pico to a computer using the USB connector. Once plugged in release the BOOTSEL button. It will now mount as a Mass Storage Device called RPI-RP2.
Now simply drag and drop the MicroPython UF2 file onto the RPI-RP2 volume. This will cause the Pico to reboot and now you are able to run MicroPython.

