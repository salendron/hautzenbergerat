---
title: "How this website was built"
date: 2021-01-31T18:55:15Z
draft: false
tags: ["blog", "webdevelopment", "hugo", "static site generator"] 
---
This whole website does not use a traditional CMS. It is 100% statically generated using [Hugo](https://gohugo.io/).
Hugo is a static site generator, which allows me to write new pages as simple and portable Markdown files and then generate the whole website based on the template I wrote for this.

## No JavaScript, no cookies, no tracking
As you might have noticed, this website does not set any cookies, it does not have any social media share buttons or integrations, there is not even a single lineof JavaScript.
There are several reasons for that. First I wanted it to be fast, therefor I used a static site generator, which means there is no need for dynamically loading content. This website is about its content, so why should I use a fancy animated template, that has no purpose, but makes reading harder.
Another reason for not using share buttons is, that besides making the site slower, they also would require you to opt-in.
There is no tracking or analytics on this page, because I don't need it. This is my private website. I do not have any financial interesst in this and I am not dependend on clicks and views. If you like what you see here, come back to see what's new from time to time.

## Sharing is caring
If you like the content you see here, feel free to copy the URL into any social media feed or messenger you want, to share it with your friends. Actually I would be very happy about this.

## Open
This whole website, incl. templates and the hugo site, is available at [Github](https://github.com/salendron/hautzenbergerat). Feel free to take a look at it and maybe use my template. I use git here, because it allows me to track changes and it's also a very easy way for me to write from wherever I want.

## Automatic builds
Since this website is on Github I am able to build and upload it automatically every night using a script that pulls the latest changes from the repository, build the website using Hugo and finally uploads it to the ftp server. The script runs on a RaspberryPi that I use as home service host. This allows me to just write content, use Hugo's built-in draft and release date functionality and push it to the repository and the cronjob will update the website automatically once per day. This and the fact that the whole content is Markdown, which can be edited with a simple text editor, allows me to write from wherever I want. In theory I could write a new article on my phone, push it to the repository and let the cronjob do its job. The script that does all of this here can be found [here](https://github.com/salendron/hautzenbergerat/blob/main/deploy_sample.sh).