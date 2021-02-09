---
title: "How to enable RaspberryPi Camera module on Ubuntu"
date: 2021-02-09T13:06:25Z
draft: false
tags: ["blog", "howto", "raspberrypi", "camera", "ubuntu"]
---
I'm running the official Ubuntu for RaspberryPi on a RaspberryPi 4 and wanted to use the RaspberryPi Camera Module. The thing is, this is not as simple as it is on Raspian. So here are the steps you have to perform to use the Camera Module on Ubuntu.

## Activate Module
First of all connect the Camera Module to your RaspberryPi like you always would and boot it up. Next you have to add the magic setting "start_x=1" to your /boot/config.txt.

```bash
sudo vi /boot/config.txt
```

Now scroll to the end of the file and add the following line, safe it and close vi.
```bash
start_x=1
```

In addition to that we also to install a few packages.

```bash
sudo apt-get install --reinstall libraspberrypi0 libraspberrypi-dev libraspberrypi-bin
```

Now reboot the RaspberyPi.

## Capture
To test the camera we can use fswebcam like this.

```bash
fswebcam -r 640x480 --jpeg 100 -D 1 --no-banner test.jpg
```
