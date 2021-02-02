---
title: "How to develop on a RaspberryPi Pico using Micropython"
date: 2021-02-02T18:25:12Z
draft: false
tags: ["blog", "howto", "raspberrypi", "raspberrypi pico", "python", "micropython", "electronics", "programming", "iot", "microcontroller"]
---
A few days ago I got two brand new RaspberryPi Pico Boards and so it is time to build something using this new toy. So let's talk about what it actually is, how to setup a MicroPython development environment and also build a simple example project to make sure everything works as expected.

## This one is not like the others
I won't go to much into the specs of this board, since you can read them for yourself [here](https://www.raspberrypi.org/products/raspberry-pi-pico/), instead I will focus here on two specific things that set's this Pi appart from others like it.
First this is a RaspberryPi, but it is no single board computer running a Linux OS like other RaspberryPis, it is a microcontroller. So we better compare it to an Arduino or an ESP32. If we compare it to an Arduino, we'll notice various technical differences, but we also see that we can not only program the RaspberryPi Pico using C/C++, like Arduinos, but also using MicroPython and that's exactly what we'll do in this article.

## Setup MicroPython
First we have to make sure that the Pico is able to run MicroPython. To do so we need to download the MicroPython UF2 file from the [RaspberryPi Pico website](https://www.raspberrypi.org/documentation/pico/getting-started/).
Now we can take our Pico and push and hold the BOOTSEL button (the big white one on the board) while connecting the Pico to a computer using the USB connector. Once plugged in release the BOOTSEL button. It will now mount as a Mass Storage Device called RPI-RP2.
Now simply drag and drop the MicroPython UF2 file onto the RPI-RP2 volume. This will cause the Pico to reboot and now you are able to run MicroPython.

## Connect
To test our connection to the Pico we use a tool called **minicom**, which we install as follows.

```bash
sudo apt install minicom
```

Now we can connect to the Pico like this.

```bash
minicom -o -D /dev/ttyACM0
```

Now press enter unitl you see ```>>>```. After that press ctrl+d. If everything is ok, you should now see something like this.

```bash
MPY: soft reboot
MicroPython v1.13-290-g556ae7914 on 2021-01-21; Raspberry Pi Pico with RP2040
Type "help()" for more information.
```

As a final test we will let the built-in LED on pin 25 blink. First we import Pin, define led as ouput on pin 25, set the value to 1, LED is on and finally turn it off by setting the pin to 0.

```python
>>> from machine import Pin
>>> led = Pin(25, Pin.OUT)
>>> led.value(1)
>>> led.value(0)
```

## Setup an IDE
We will use Thonny to develop for the RaspberryPi Pico. This can be installed on a RaspberryPi via pip.

```bash
pip install thonny
```

When Thonny starts for the first time make sure to select regular mode imstead of standard mode. We also need to download the Pico backend wheel from [Github](https://github.com/raspberrypi/thonny-pico/releases/latest). Start Thonny and navigate to "Tools → Manage plug-ins" and click on the link to "Install from local file", and select the Pico backend wheel. Click the "Close" button to finish. Now restart Thonny to activate it.
Now go to "Tools → Options → Interpreter" and select "Micropython (RaspberryPi Pico)".

## Blink Sample
Let's built a very simple sample program that blinks the built-in LED on pin 25.

```python
from machine import Pin, Timer

led = Pin(25, Pin.OUT)
tim = Timer()

def tick(timer):
    global led
    led.toggle()

tim.init(freq=2.5, mode=Timer.PERIODIC, callback=tick)
```

Press the run button in Thonny and if everything is ok, the green LED on the Pico should start to blink. That's it, now you've got a running development environment for your RaspberryPi Pico.

## Bonus: Temperature Example

The Pico has a built in temperature sensor, so why not use it. This simple example reads the sensors value every second, converts it to degrees celsius and prints the result.

```python
import machine
import utime

sensor_temp = machine.ADC(machine.ADC.CORE_TEMP)
conversion_factor = 3.3 / (65535)

while True:
    reading = sensor_temp.read_u16() * conversion_factor
    temperature = 27 - (reading - 0.706)/0.001721
    print(temperature)
    utime.sleep(1)
```