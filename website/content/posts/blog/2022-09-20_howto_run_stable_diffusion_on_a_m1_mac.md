---
title: "Howto run Stable Diffusion Text2Image Generator locally on an M1 Mac"
date: 2022-09-20T16:00:25Z
draft: false
tags: ["blog", "howto", "python", "tensorflow", "ml", "maschine learning", "keras", "text2image", "macos"]
cover: "/images/stablediffusion/cover.jpg"
images: ["/images/stablediffusion/001.jpg","/images/stablediffusion/002.jpg","/images/stablediffusion/003.jpg","/images/stablediffusion/004.jpg","/images/stablediffusion/005.jpg","/images/stablediffusion/006.jpg","/images/stablediffusion/007.jpg","/images/stablediffusion/008.jpg","/images/stablediffusion/009.jpg","/images/stablediffusion/010.jpg","/images/stablediffusion/011.jpg","/images/stablediffusion/012.jpg","/images/stablediffusion/013.jpg"]
---
Text2Image generators like Dall-E or Midjourney are the new hot dudes, when it comes to generating images just from text inputs and also sparked some serious discussions about certain professions might getting obsolete, like artists and photographers.

To be honest, it is extremly impressive what these generators can do, but on the other hand they do not replace a photographer for your weddding. Nevertheless I absolutly see practical applications for Text2Image generators. I've attached some sample outputs at the end of this post, which I have generated myself using Stable Diffusion on my M1 Mac Mini. There are "chairs that look like an avocado", beautiful landscapes and even examples of really detailed graphics in various art styles. 

So, before we go into the details of how you run Stable Diffusion on your local machine, let me tell you what I think about them. Yes, results of these generators can win art prices (this actually happened) and yes, if you need inspiration for a product designs, a new wallpaper, graphical assets, or even just a generic stock photo, then these generators will be and are already a real alternative to humans, if you have enough computational power.

## Prequesites
You will need a working Tensorflow environment on your Mac. Luckily I've already written a tutorial on how to set this up [here](https://hautzenberger.at/posts/blog/2021-12-19_setup_tensorflow_env_on_m1_macos/). So just follow this tutorial and then continue with the specific setup of Stable Diffusion here.

## Stable Diffusion Setup
In your activated Tensorflow environment you have to install these additional packages using pip. 

```bash 
pip install git+https://github.com/fchollet/stable-diffusion-tensorflow 
pip install tensorflow_addons ftfy
pip install tqdm                  
```
That's it. You are ready to go. 

## Example Code
So let's take a look at some example code, but before doing so I want to warn you about a few limitations I've noticed when running this on my Mac Mini. A batch size bigger than 1 and image sizes bigger than 512x512 pixel do not work, because of hardware limitations. Therefor I've implemented a loop to generate more than one image for each prompt and since I do not want to restart the script for every prompt, I've put another loop arround it to loop over prompts. So I can enter a lot of prompts and just let the script run for hours in the background. 

Another thing you should be aware of is that when you run the script for the first time it will download the model, which is pretty big, so this will take some time. This happens only the first time you run the script.

```python
from stable_diffusion_tf.stable_diffusion import Text2Image
from PIL import Image
import os

prompts = [
    "paraglider in the mountains sunset hyperealistic",
    "retro space travel",
    "a chair that looks like an avocado",
    "a pixelart hero",
    "a fast car, DSLR photo"
]
results = 6

for prompt in prompts:
    for i in range(results):
        generator = Text2Image( 
            img_height=512,
            img_width=512,
            jit_compile=False,  
        )
        img = generator.generate(
            prompt,
            num_steps=50,
            unconditional_guidance_scale=7.5,
            temperature=1,
            batch_size=1,
        )

        pil_img = Image.fromarray(img[0])
        pil_img.save(f"{prompt}_{i}.jpg")
```
## Sample Results