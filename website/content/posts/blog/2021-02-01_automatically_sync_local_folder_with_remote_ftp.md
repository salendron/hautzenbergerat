---
title: "Automatically sync local folder with remote ftp"
date: 2021-02-01T18:50:11Z
draft: false
tags: ["blog", "scripting", "bash", "ftp", "automation"]
---
As I've already mentioned in my article about [how this website was built](/posts/blog/2021-01-31_how-this-website-was-built/), this website get's updated every night automatically with content I wrote the day before.
To do so I use a cronjob and a little script that get's the latests version of this website from Github, builds it and then uploads it via ftp. Since mirroring a local directory with a remote ftp directory is a pretty common task, I thought it would make sense to write about how I did it.
The whole script, incl. the part in which it pulls the latest changes from Github and builds the website using [Hugo](https://gohugo.io/), can be found [here](https://github.com/salendron/hautzenbergerat/blob/main/deploy_sample.sh). In this post I will only focus on the ftp-mirroring part of this.

## lftp

First of all we need to install lftp. In my setup I use a RaspberrPi, which I use as service host, so it is running all the time and therefor perfect for running scripts at night.

```bash
sudo apt-get install lftp
```

## script it

Let's assume the following. Your ftp host is at **mysupercoolwebsite.com**, your user is **myawesomeuser**, your password is **mysupersafepassword**, your local directory to upload is at **/home/myuser/localwebsitefolder** and your target directory on the remote ftp is **/**, then your script will look like this. Of course you'll have replace all of our assumptions with the actual values of your setup.

```bash
#!/bin/bash
HOST='mysupercoolwebsite.com'
USER='myawesomeuser'
PASS='mysupersafepassword'
TARGETFOLDER='/'
SOURCEFOLDER='/home/myuser/localwebsitefolder'

lftp -f "
open $HOST
user $USER $PASS
lcd $SOURCEFOLDER
mirror --reverse --delete --verbose $SOURCEFOLDER $TARGETFOLDER
bye
"
```

This script opens a connection to the ftp host, logs in and then mirrors your local folder with the remote folder. Be careful, because it will also delete files there if they do not exist locally.

## run it

As mentioned I want this to run every night at 4AM, so we'll use a cronjob to run the script, but first we have to make the script executable.

```bash
sudo chmod +x /path_to_script/upload.sh
```

Now we can configure the actual cronjob to do the job. We use the root crontab here. Feel free to do that differently, if you want to.

```bash
sudo crontab -e
```

In here we add the following line to make it run every day at 4AM and save it.

```bash
 0 4 * * * /path_to_script/upload.sh
```

And that's it. Our local folder will now be uploaded to our ftp host every night and we do not have to worry about that anymore.