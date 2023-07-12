---
title: "I wish these photos were taken by me, but AI took my job"
date: 2023-07-12T17:00:02Z
draft: false
tags: ["photography", "ai", "aiart", "stablediffusion", "text2image", "style", "blog"]
cover: "/images/photography/my_ai_style/001.jpg"
images: ["/images/photography/my_ai_style/001.jpg", "/images/photography/my_ai_style/002.jpg", "/images/photography/my_ai_style/003.jpg", "/images/photography/my_ai_style/004.jpg", "/images/photography/my_ai_style/005.jpg",
"/images/photography/my_ai_style/006.jpg", "/images/photography/my_ai_style/007.jpg", "/images/photography/my_ai_style/008.jpg", "/images/photography/my_ai_style/009.jpg", "/images/photography/my_ai_style/010.jpg", "/images/photography/my_ai_style/011.jpg"]
---
Is this title clickbait? Maybe, but I really wish that these photos were taken by me using one of my lovely old analog cameras on good old color film. AI did not really take my job, but just because I am not a professional photographer. I take photos for fun. It is my hobby. I have no preassure. The only one who has to like my work is myself.

**And actually that's kind of the problem.**

I hate most of my own photos. I like a few and I really like probably less than 5. I am still struggeling with finding my style. If you scroll through my instagram feed you'll notice that my style changes over time and still I do not feel like I've found what I am looking for. There are several photographers which I totally adore, like Joel Meyerowitz, Maria Lax, Todd Hido, to name a few. I like their style even though I can't describe it. There is something in me that tells me, if I like something or not, but it feels impossible for me to force myself to produce things I like, since I can not describe what I like in a way that allows me to produce it. 

## Let AI handle this

So I had an idea. I tried to write down what I feel when looking at pictures, describe it with adjectives and added in some locations that I might like.

**LIMINAL, OMINOUS LIGHT, IMPLIED PRESENCE, A HIDDEN STORY, MINIMAL**

I formulated lot's of prompts that followed those ideas and let the AI do the rest. What you see here, if you scroll down to the bottom of the page, are a few of the results, the ones I liked. As you might have noticed these are not the classic "beautiful" pictures, but they are what I was looking for. This is what I want my work to be. These photos speak to me, leave room for a story, a feeling, an interpretation.

AI did a better job than me. Is this bad? No. Will I stop taking photos? No. So why doing all of this? Generating photos using very vague descriptions of how I want photos to feel and getting results like this is an awesome inspiration for me. I take this as a starting point for me to evolve my work and maybe create more photos I like in the future.

## equipment

I used an Apple MacMini running various StableDiffusion Models locally using a simple Python script, which you can see here.

First install dependencies...

```bash
pip install diffusers transformers accelerate scipy safetensors
```

...and here is the script. You can find lots of models to try out at [https://huggingface.co/](https://huggingface.co/)

```python
import torch
import os
from diffusers import StableDiffusionPipeline, DPMSolverMultistepScheduler

model_id = "dreamlike-art/dreamlike-photoreal-2.0"

pipe = StableDiffusionPipeline.from_pretrained(model_id)
pipe.scheduler = DPMSolverMultistepScheduler.from_config(pipe.scheduler.config)
pipe.enable_attention_slicing()

prompts = [
    "cinematic minimalistic color photo of lonely house with a ominous light in one window",
    "cinematic minimalistic color photo of a liminal space scene at night",
]


results = 10
loops = 10

for j in range(loops):
    for i in range(results):
        for prompt in prompts:
            image = pipe(prompt, height=1024, width=1024).images[0]
            image.save(os.path.join("/Users/brunohautzenberger/Library/Mobile Documents/com~apple~CloudDocs/Photos/Generated/stablediffusion_v2/results_20230712", f"{prompt}_loop_{j}_{i}.jpg"))
```