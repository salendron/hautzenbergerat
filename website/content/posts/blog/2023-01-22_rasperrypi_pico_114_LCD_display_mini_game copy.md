---
title: "Programming a mini game on a RaspberryPi Pico using a 1.14‘‘ LCD screen"
date: 2023-01-21T14:00:25Z
draft: false
tags: ["blog", "howto", "microcontroller", "mycropython", "rapsberrypi", "raspberrypi pico", "game", "gamedev"]
cover: "/images/rasperrypi_pico_mini_game.png"
---
I recently bough [this 1.14‘‘ LCD screen](https://www.waveshare.com/wiki/Pico-LCD-1.14) for the RaspberryPi Pico. This screen not only just fits perfectly onto the Rasperry, you literally just put it over all of the pin headers, it also comes with a little analog pad, up, down, left, right, as well as an A and B button. So it is already kind of a very small handheld gaming device.

## The Game
It is really simple, the player, a little green square on the left side of the screen, can move up and down using the analog pad, and shoot lasers using the A button.  
On the right side of the screen three red enemies will spawn, which the player has to hit with its lasers. But be careful! The enemies will also shoot lasers and as soon as the player was hit 10 times the game is over and can be restarted by pressing the B button. Of course the player get‘s a point for each enemy hit by a laser and the enemy will just respawn on top of the screen.

## Implementation
I implemented this using Micropython, which is in my opinion the best was to develop on a RaspberryPi Pico. Thankfully there is [sample code](https://www.waveshare.com/wiki/Pico-LCD-1.14#Download_Demo_codes) on how to interact with the display provided by the manufacturer, which also includes a class called LCD. I use this LCD class throughout the whole game to draw on the display and also to get the button press events.


The implementation itself is very simple. „main.py“ contains the endless game loop, which on the one hand reads all the events and takes care of the frame rate using a very simple game clock implementation and on the other hand calls the „draw“ method of the scene and passes all events to it.
The scene is basically our game controller. It contains all other object, the player, the enemies, the status bar and so on and also calls „draw“ for each of them on every tick of the clock. That way everything get‘s drawn in the right order for each frame and by passing down the events, all objects can also react to them. This is important so the player can actually move up and down and also shoot laser, if the right button was pressed.
The scene also takes care of collisions. Since it knows about the position of every object within each frame, we use the scene to detect if a laser hit the player or an enemy and either increase the points of the player or decrease its health. If the player health reaches 0, we also end the game by showing a „Game Over“ message and wait for the B button to be pressed so the scene can initialize a new game.

## Source Code
You can get the source code of this little game [here](https://github.com/salendron/rasperrypi_pico_114tft_minigame). Fell free to use it as a starting point for your own little game or, if you want to play that game yourself, just upload it to your RaspberryPi Pico with the 1.14‘‘ LCD display attached.