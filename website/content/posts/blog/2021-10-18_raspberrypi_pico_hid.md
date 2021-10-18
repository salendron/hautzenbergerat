---
title: "Raspberry Pi Pico as HID"
date: 2021-10-18T17:00:25Z
draft: false
tags: ["blog", "howto", "raspberrypi", "raspberrypi pico", "python", "circutpython", "electronics", "programming", "iot", "microcontroller"]
cover: "/images/raspberrypipicocontroller.jpg"
---
Ever wanted to build a custom controller, or a have a few buttons which you could map some shortcuts to? Then the RaspberryPi Pico and a few touch buttons are everything you need. The Pico can be used as a HID (Keyboard, Mouse or MediaController) by using Adafruit's HID library. The only problem here is that you can not use it using Micropython, but if we setup the Pico to run Circutpython we are good to go.
In this example I've build a custom controller, which acts as a keyboard with W,A,S,D keys as well as the ESC button and Spacebar. This is enough for me to control a simple space invaders game. WASD to move, Spacebar to shoot and ESC to start the game.

## Wiring the button
The buttons  have two wires attached to them. We simply connect one end to a digital pin and the other one to GND on the Pico. I did this for all six buttons and used D10 to D15 as digital pins.

## Setting up Circut Python
To be able to run Circutpython on the Pico we first need to download the .uf2 from [circuitpython.org](https://circuitpython.org/board/raspberry_pi_pico/). Then we hold down the button on the Pico while plugging it into our PC via USB. The Pico will connect as an external media source and we can copy the uf2 file onto it. This will cause the Pico to restart and run Cicutpython.

## Adding the HID Library
To allow the Pico to act as a HID we need Adafruit's HID library. We can simply download the whole library bundle from (here)[https://circuitpython.org/libraries] and unzip it. Now we create a lib Folder on the Pico and copy the adafruit_hid directory from lib folder in the library bundle into it. 

## The Code
Now we create a new python file called "code.py" and copy the follwing code into it. If you used other digital pins or want to use a different layout you can just adjust the script to fit your needs.

What it basically does is, that it sets every button up with its digital pin, configured as DigitalInOut, set its direction to input, so we can read its value and lastly set pull to up. 

We do this for every button and after that we add an infinite loop which checks for the inverse value of the button. Its default value while the button is not pressed will be 1, therefor we invert it. If a button get's pressed, value 0, we use the HID keyboard module to send the keycode of the button we want to emulate.
Now we copy that file to the root directory of the Pico and we are done.
```python
import time
import usb_hid
from adafruit_hid import keyboard
import board
import digitalio

btnESC = digitalio.DigitalInOut(board.GP14)
btnESC.direction = digitalio.Direction.INPUT
btnESC.pull = digitalio.Pull.UP

btnSPACE = digitalio.DigitalInOut(board.GP15)
btnSPACE.direction = digitalio.Direction.INPUT
btnSPACE.pull = digitalio.Pull.UP

btnup = digitalio.DigitalInOut(board.GP13)
btnup.direction = digitalio.Direction.INPUT
btnup.pull = digitalio.Pull.UP

btndown = digitalio.DigitalInOut(board.GP11)
btndown.direction = digitalio.Direction.INPUT
btndown.pull = digitalio.Pull.UP

btnleft = digitalio.DigitalInOut(board.GP12)
btnleft.direction = digitalio.Direction.INPUT
btnleft.pull = digitalio.Pull.UP

btnright = digitalio.DigitalInOut(board.GP10)
btnright.direction = digitalio.Direction.INPUT
btnright.pull = digitalio.Pull.UP

kbd = keyboard.Keyboard(usb_hid.devices)

while True:
    if not(btnESC.value):
        print("ESC")
        kbd.send(keyboard.Keycode.ESCAPE)
        
    if not(btnSPACE.value):
        print("SPACE")
        kbd.send(keyboard.Keycode.SPACEBAR)
        
    if not(btnup.value):
        print("W")
        kbd.send(keyboard.Keycode.W)
        
    if not(btndown.value):
        print("S")
        kbd.send(keyboard.Keycode.S)
        
    if not(btnright.value):
        print("A")
        kbd.send(keyboard.Keycode.A)
        
    if not(btnleft.value):
        print("D")
        kbd.send(keyboard.Keycode.D)
```

## Testing
Now we can connect the Pico via USB to any PC, or even an IPad Pro via a USB adapter, and test it with a text editor or any other program which will react to the keys we have mapped to our buttons. 

