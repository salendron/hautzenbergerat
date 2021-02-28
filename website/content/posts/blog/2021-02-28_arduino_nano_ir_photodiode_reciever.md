---
title: "How to use a IR photodiode on an Arduino to meassure IR light"
date: 2021-03-01T20:10:28Z
draft: false
tags: ["blog", "howto", "arduino", "arduino nano", "photodiode", "infrared", "electronics", "programming", "iot", "microcontroller"]
---
Most tutorials I've found so far are about 3-pin photodiodes. These are meant to recieve digital IR signals from TV remotes or similar devices. The 2-pin diodes can be used to simply meassure the available IR light. So you could use this to build a distance sensor, if you add a IR LED emitter and then meassure the reflected light, or to meassure the IR light emitted by a natural or artificial light source. In this article I'll describe how to use a 2-pin diode on an Arduino and read the IR light value meassured by the diode.

## Wiring
The short side of the diode has to connected to 3.3V and the long side to analog pin A0. We also connect the long side via a 10k ohm resistor to ground. 

## Coding
To read from the diode we simply setup pin A0 to Input so we can read the data via analogRead and output the value to serial.

``` c+++
int irRead;

void setup() {
  Serial.begin(9600);
  pinMode(A0, INPUT);

}

void loop() {
    irRead = analogRead(A0); 
    Serial.println(irRead);
    delay(100);
}
```
