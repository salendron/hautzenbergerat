---
title: "A RaspberryPi Pico To-Do board using Micropython"
date: 2022-08-21T17:00:12Z
draft: false
tags: ["blog", "howto", "raspberrypi", "raspberrypi pico", "python", "micropython", "electronics", "programming", "iot", "microcontroller"]
cover: "/images/domachine.jpeg"
---
Sometimes I need a little visual hint to do things, especially when it comes to little things that I should do on repeat, like dayli or even multiple times per day. 
I'm not really someone who does a lot of sport, but I love to go bouldering. In my "best times" I went three times every week. A few weeks ago I injured my left leg and since then I was not able to go to the bouldering gym anymore. So, what did I do? Right, nothing.

To motivate me to do at least a few exercises at home everyday I thought a little To-Do board that automatically reminds me to do something could help.

## How it works
The whole solution is vers simple. It consists of a RaspberryPi Pico, 5 buttons and 5 LEDs. Basically what it does is, that as long as the LEDs are on you have to do whatever the To-Do wants you to do. I just taped my execises next to the LEDs. As soon as you've done it, you push the button next to the To-Do and the LED is turned of until it will turn on again after a configured time.
The fifth button is used as a snooze button. If you press it, it will turn of all LEDs off for 12 hours. Use this to turn the whole thing off over night. The fifth LED is next to the snooze button and simply shows that the board is on. It will also shut down, if you press snooze.

## Wiring
Again this is a really simple project, so everythin you have to do is to connect every button to a GPIO pin on the one side and to GND on the other side. The same goes gor all the LEDs. Just make sure that you connect the shorter end of the LED to GND and not the other way arround. The pin numbers I used can be found in the code below.

## The Code
First we neew to import Pin and time and setup all the pin numbers, which we connected our LEDs and Buttons to.

```python
from machine import Pin
import time

ledSnooze = 18
ledPin1 = 19
ledPin2 = 20
ledPin3 = 21
ledPin4 = 22

btnPin1 = 9
btnPin2 = 8
btnPin3 = 11
btnPin4 = 12
btnPin5 = 13
```

Now we can setup our LEDs and buttons so we can read button states and turn the LEDs on and off.

```python
ledSnooze = Pin(ledSnooze, Pin.OUT)
led1 = Pin(ledPin1, Pin.OUT)
led2 = Pin(ledPin2, Pin.OUT)
led3 = Pin(ledPin3, Pin.OUT)
led4 = Pin(ledPin4, Pin.OUT)

btnSnooze = Pin(btnPin1, Pin.IN, Pin.PULL_UP)
btn1 = Pin(btnPin2, Pin.IN, Pin.PULL_UP)
btn2 = Pin(btnPin3, Pin.IN, Pin.PULL_UP)
btn3 = Pin(btnPin4, Pin.IN, Pin.PULL_UP)
btn4 = Pin(btnPin5, Pin.IN, Pin.PULL_UP)
```

As I said the LEDs will automatically turn back on after some time. In my setup done To-Dos will come back up again after 4 hours, 60 * 60 * 4, and I'll store that in the waitTime variable. The snoozeTime variable holds the seconds that have to pass until the board turns back on after we've pressed the snooze button. In my case this will take 12 hours, 60*60*12.

```python
waitTime = 60 * 60 * 4
snoozeTime = 60 * 60 * 12
```

To remember when each button was pressed for the last time we store this information in 5 variables, 4 To-Dos + the snooze button, and initially set the last time pressed to now - the time it would take to come back on again. This way all To-Dos will be available as soon as the board get's turned on.

```python
snoozeLastTimePressed = time.ticks_ms() - (snoozeTime * 1000)
task1LastTimePressed = time.ticks_ms() - (waitTime * 1000)
task2LastTimePressed = time.ticks_ms() - (waitTime * 1000)
task3LastTimePressed = time.ticks_ms() - (waitTime * 1000)
task4LastTimePressed = time.ticks_ms() - (waitTime * 1000)
```

Now we just need a little helper function to get the button state, pressed or not. Since the buttons will return 1, if they are not pressed, this function will return *not button.value()", so we get a 1, or True in this case, if the button was pressed.

```python
def getButton(btn):
    return not btn.value()
```

Next we create a main loop, which doesn the following:
* check if snooze was pressed within the last 12 hours and if that is true, turn off all LEDs and skip this loop.
* check each button state and if one was presssd, set the last time pressed time to now.
* lastly check if any button was pressed within the last 4 hours and if that is the case, turn off the LED for that To-Do.

```python
while True:
    if time.ticks_diff(time.ticks_ms(), snoozeLastTimePressed) / 1000 < snoozeTime:
        ledSnooze.value(0)
        led1.value(0)
        led2.value(0)
        led3.value(0)
        led4.value(0)
        continue
    else:
        ledSnooze.value(1)
    
    if getButton(btnSnooze):
        print("btnSnooze pressed")
        snoozeLastTimePressed = time.ticks_ms()
        
    if getButton(btn1):
        print("btn1 pressed")
        task1LastTimePressed = time.ticks_ms()
        
    if getButton(btn2):
        print("btn2 pressed")
        task2LastTimePressed = time.ticks_ms()
        
    if getButton(btn3):
        print("btn4 pressed")
        task3LastTimePressed = time.ticks_ms()
        
    if getButton(btn4):
        print("btn5 pressed")
        task4LastTimePressed = time.ticks_ms()
        
    if time.ticks_diff(time.ticks_ms(), task1LastTimePressed) / 1000 > waitTime:
        led1.value(1)
    else:
        led1.value(0)
        
    if time.ticks_diff(time.ticks_ms(), task2LastTimePressed) / 1000 > waitTime:
        led2.value(1)
    else:
        led2.value(0)
        
    if time.ticks_diff(time.ticks_ms(), task3LastTimePressed) / 1000 > waitTime:
        led3.value(1)
    else:
        led3.value(0)
        
    if time.ticks_diff(time.ticks_ms(), task4LastTimePressed) / 1000 > waitTime:
        led4.value(1)
    else:
        led4.value(0)
        
    time.sleep(0.1)
```

That's it, you've created a To-Do board for repeating To-Dos. The only thing missing now is a case, but I leave it up to you to design and build that. The whole source code for this project can be found [here](https://github.com/salendron/DoMachine).