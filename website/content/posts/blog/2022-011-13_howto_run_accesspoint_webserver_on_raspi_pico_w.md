---
title: "Dead Letter Box - How to run a webserver on a RaspberryPi Pico W and use it as a standalone WiFi Accesspoint"
date: 2022-11-13T16:00:25Z
draft: false
tags: ["blog", "howto", "microcontroller", "mycropython", "rapsberrypi", "raspberrypi pico", "webserver"]
---
We all know the stories of spies placing letters in hidden dead letter boxes during foggy cold november nights to communicate with other spies. Since the year is 2022 now, we will build something like this, but using a RaspberryPi Pico W 2. Basically the Raspberry Pi will act as a WiFi Accesspoint, which you can connect to without the actual need of physical contact with the device. The Raspberry Pi will also run a webserver, which we will use to to read and store messages, for anybody else who knows where the WiFi can be found and also have the password.

## Prequesites
You will need to setup micropython on your Raspberry Pi Pico and also an IDE to develop and deploy Micropython applications on it. Google will help you do that. ;-)

## Helpers
First we will implement some helpers, which we will use later on. First we need a helper to turn the onboard LED on and off, to indicate that the webserver is running and we will also implement a helper to read the temperature sensor, just for fun.

### status.py
```python 
from machine import Pin

led_onboard = Pin("LED", Pin.OUT)

def set_status(on):
    if on:
        led_onboard.on()
    else:
        led_onboard.off()            
```

### temp.py
```python 
import machine 

sensor_temp = machine.ADC(4)

conversion_factor = 3.3 / (65535)

def get_temp():
    reading = sensor_temp.read_u16() * conversion_factor
    return (27 - (reading - 0.706)/0.001721)
```
        
## Access Point
Next we will implemnent the access point, which is pretty easy using the network package. Feel free to change your network name and password.

### ap.py
```python
import network
import rp2

def start_ap():
    rp2.country('AT')
    ap = network.WLAN(network.AP_IF)
    ap.config(essid='Dead Letter Box', password='12345678')
    ap.active(True)

    netConfig = ap.ifconfig()
    print('IPv4-Adresse:', netConfig[0], '/', netConfig[1])
    print('Standard-Gateway:', netConfig[2])
    print('DNS-Server:', netConfig[3])     
```
## Webserver
Next we will implement the webserver. This file is a little bigger so we will start by implementing some helpers. read_html will be used to load our only html website, write_msg and read_msgs are used to load and save messages on the buildin storage. We store all the messages in a json string array and we will limit messages to 10 so we do not run out of space.

```python
def read_html():
    f = open("index.html", "r")
    html = f.read()
    f.close()
    return html

def write_msg(msg):
    msgs = read_msgs()
    f = open("msgs.txt", "w")

    msg = msg.replace("%20", " ")
    msgs["items"].append(msg)

    if len(msgs["items"]) > 10:
        msgs["items"] = msgs["items"][-10:]

    f.write(json.dumps(msgs))
    f.flush()
    f.close()

def read_msgs():
    try:
        f = open("msgs.txt", "r+")
        content = f.read()
        print(content)
        f.close()
        msgs = json.loads(content)
        return msgs
    except Exception  as e:
        print(e)
        return json.loads('{"items":[]}')
```

Next we implement the actual webserver using the socket package. As soon as the webserver is started we will switch on the status LED and wait for incoming connections. As soon as we get a request to / we will serve the website. If our path starts with "msg:" we will save everything after that as a new message.

```python
def run_webserver():
    print('Starting web server...')
    addr = socket.getaddrinfo('0.0.0.0', 80)[0][-1]  # type: ignore
    server = socket.socket()   # type: ignore
    server.bind(addr)
    server.listen(1)
    print('Server Listener on ', addr)

    set_status(True)

    while True:
        try:
            conn, addr = server.accept()
            print('New HTTP-Request from ', addr)
            request = str(conn.recv(1024)).split('\\r\\n')
            request = request[0].split(' ')

            if len(request) > 1:
                path = request[1].lstrip('/')
                print('Request:', path)

                if path.startswith("msg:"):
                    value = path.lstrip("msg:")
                    value = value.strip()

                    if len(value) > 0:
                        write_msg(value)

            msgs = ""
            for item in read_msgs()["items"]:
                msgs = "<p>-> <b>" + item + "</b></p><hr>" + msgs

            response = read_html().replace("#MSGS#", msgs)
            response = response.replace("#TEMP#", str(get_temp()))
            conn.send('HTTP/1.0 200 OK\r\nContent-type: text/html\r\n\r\n')
            conn.send(response)
            conn.close()
            print('HTTP-Response handled')
        except OSError as e:
            break
        except (KeyboardInterrupt):
            break

        try: 
            conn.close()   # type: ignore
        except NameError: 
            pass

    server.close()
    print('Web server stopped')
```

## main.py
Lastly we need to implement a main.py file which first starts the AccessPoint and then the webserver.

```python
from ap import start_ap
from server import run_webserver

start_ap()
run_webserver()

while True:
    pass
```

## Source Code
The  whole source code for this application can, as always, be found [here on Github](https://github.com/salendron/DeadLetterbox).