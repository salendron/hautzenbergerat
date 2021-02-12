---
title: "Arduino Nano IoT accelerometer data to pitch and roll"
date: 2021-02-12T19:07:29Z
draft: false
tags: ["blog", "howto", "arduino", "arduino nano", "accelerometer", "c++", "electronics", "programming", "iot", "microcontroller"]
---
The Arduino Nano 33 IoT comes with a built-in 3-axis acceleromteter. This sensor meassures values for x, y and z acceleration between -1 and 1. If we want to know the actual position in which the sensor is, we need to know it's rotation on two axis, pitch and roll, in dregress. This two angles could be used then later on to control two servos which rotate an object exactly the same way the sensor is rotated. Imagine a glove, that allows you rotate a camera remotly based on the rotation of your hand for example.

# The Problem
As mentioned we get x, y and z acceleration as values between -1 and 1, but we need pitch and roll between -180° and 180°. Since the sensor could rotate arround two axis at the same time, we need two consider all three values at the same time to calculate pitch and roll, because various sensor states could lead to the same pitch with a different roll and vice versa.

# The Solution
There is a formula for that! I won't bother you with the details about that here, if you want to know more details use Google. I'm just here to show you a working solution, which looks like this:

```c
int calculateRoll(float x, float y, float z) {
  return atan2(y , z) * 57.3;
}

int calculatePitch(float x, float y, float z) {
  return atan2((- x) , sqrt(y * y + z * z)) * 57.3;
}
```

If you just pass the raw accelerometer data, values between -1 an 1 for x, y and z acceleration, to these functions, they will return the current pitch and roll as values between -180 and 180. Now you could pass these values to two servos for example to rotate an object the same way as the sensor.
Here is the whole sketch for the Arduino Nano, but the formulars themselfs are of course valid for any other microcontroller or accelerometer.

```c
#include <Arduino_LSM6DS3.h>

float gX, gY, gZ;
float pitch, roll;

int calculateRoll(float x, float y, float z) {
  return atan2(y , z) * 57.3;
}

int calculatePitch(float x, float y, float z) {
  return atan2((- x) , sqrt(y * y + z * z)) * 57.3;
}

void setup() {
  // setup accelerometer and gyro n
  if (!IMU.begin()) {
    Serial.println("Failed to initialize IMU!");
    while (true);
  }
}

void loop() {
  if (IMU.gyroscopeAvailable()) {
    IMU.readAcceleration(gX, gY, gZ);
    pitch = calculatePitch(gX, gY, gZ);
    roll = calculateRoll(gX, gY, gZ);
    String result = "Pitch:" + String(pitch) + " Roll:" + String(roll);
    Serial.println(result);
    
    delay(200);
  } else {
    Serial.println("Gyroscope not available!");
    while(true);
  }
}
```


