---
title: "RaspbeeryPi Pico Temperature Light and Logger"
date: 2021-02-07T15:58:55Z
draft: false
tags: ["blog", "howto", "raspberrypi", "raspberrypi pico", "python", "micropython", "electronics", "programming", "iot", "microcontroller"]
---
On a rainy sunday afternoon I found out that the RaspbeeryPi Pico fits perfectly into a 35mm film box if you cut a little hole for the USB port into the lid. Since my box was a semi-transparent white box, I decided to add some LEDs and build a little temperature sensor, that indicates the current temperature range using either a blue, green, orange or red LED.

## Build
I connected the power pin (long side) of each LED to a GPIO port (green = Pin4, blue = Pin5, orange = Pin3, red = Pin2), of course with a 220 ohm resistor in between, and all the short sides to GND. Very simple, as I said.

## Program
As simple as the build itself is also the program. First we initialize all the LEDs, including PIN25 which is the built-in LED, which we will be used to show the moment the RaspberryPi is updating its temperature.
Then we initialize the built in temperature sensor and the conversion factor, which we will need to convert the temperature data to degress celsius.
After that I implemented three helper functions. "getTemp" is used to get the current temperature, "getNewFileName" is used to get a new filename everytime the RaspberryPi get's turned on, otherwise we would override our data all the time, and lastly "writeTemp", which we use to write temperature data to a file, which we can later access via the USB port. So, yes, this is also a temperature logger.
The last thing we have to do is to write our main loop, that reads the current temperature, writes the data to a file and then sets the LEDs according to the current temperature. The way it is implemented here, makes it great for indoor use. If you want to use it outdoors, you might want to adjust the values for each color.
At the end of the loop we add a sleep statement, so it does not log data all the time. For me every 30 minutes is more than enough.

```python
from machine import Pin
import time
from os import listdir

red = Pin(2, Pin.OUT)
orange = Pin(3, Pin.OUT)
blue = Pin(5, Pin.OUT)
green = Pin(4, Pin.OUT)
status = Pin(25, Pin.OUT)

sensor_temp = machine.ADC(machine.ADC.CORE_TEMP)
conversion_factor = 3.3 / (65535)

def getTemp():
    reading = sensor_temp.read_u16() * conversion_factor
    return (27 - (reading - 0.706)/0.001721)

def getNewFileName():
    files =  [f for f in listdir(".") if f.endswith(".txt")]
    return "{}.txt".format(len(files))

def writeTemp(temp, f):
    f.write("{}\n".format(temp))
    f.flush()

recordFile = open(getNewFileName(), "w")
while True:
    status.value(1)
    temp = getTemp()
    writeTemp(temp, recordFile)
    print(temp)
    time.sleep(0.5)
    status.value(0)
    
    red.value(0)
    orange.value(0)
    green.value(0)
    blue.value(0)
    
    if temp > 28:
        red.value(1)
    elif temp > 25:
        orange.value(1)
    elif temp > 22:
        green.value(1)
    elif temp > 19:
        green.value(1)
        blue.value(1)
    else:
        blue.value(1)
        
    time.sleep(30 * 60)
```

Now you can deploy this to your RaspberryPi Pico and it should light up depending on the current temperature.