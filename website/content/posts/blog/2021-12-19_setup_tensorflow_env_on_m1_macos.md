---
title: "Setup Tensorflow Environment on M1 Mac"
date: 2021-12-19T12:00:25Z
draft: false
tags: ["blog", "howto", "mac", "macos", "python", "apple", "tensorflow", "ml", "maschine learning"]
---
Since Apple's M1 chip is a really good choice for maschine learning at home, but the setup of a Tensorflow environment isn't exactly straight forward, I thought it would make sense to simplify it a little bit and write a short guide on how to do it.

## What we need and what the finished solution will look like
We need a Apple device with a M1, M1 Pro or Max work the same way, chip and macOS 12.o or higher. We will then setup a Conda and install all the dependencies for Tensorflow on MacOS. After that we can use a little script to create a new isolaten Tensorflow environment for each of our Tensorflow projects.

## Setup Conda
Installing COnda is actually straight forwards.Just Download the installer script from [here](https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-arm64.sh) and the execute the following commands in a terminal to install Conda to your home directory.
```bash
chmod +x ~/Downloads/Miniforge3-MacOSX-arm64.sh
sh ~/Downloads/Miniforge3-MacOSX-arm64.sh
```

## Setup a project environment
Everytime we start a new Tensorflow project we now only need to create a new directory and execute a little script I wrote inside of it to set it up automatically. You can find the script [here](https://github.com/salendron/tensorflow_examples/blob/main/MacOS_M1_Tensorflow_Setup/setup_tensorflow_env.sh).
I suggest that you just download the script and put somewhere in your PATH so you can access it from everywhere. Now the you have the script just enter your new project directory in a terminal and execute the script here. It will setup a Python venv and install everything you need to start your Tensorflow project as well as activate all environments so you can start coding right away.
To test ist just type **python3** in you console and then try if **import tensorflow** works. If you can execute **tensorflow.__version__** now, everything is fine.


