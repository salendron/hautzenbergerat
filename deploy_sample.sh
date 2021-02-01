#!/bin/bash
HOST='www.you-host.com'
USER='your-user'
PASS='your-password'
TARGETFOLDER='/public_html'
SOURCEFOLDER='...'
BUILDROOTFOLDER='...'
WEBSITEFOLDER='...'

mkdir $BUILDROOTFOLDER
cd $BUILDROOTFOLDER
git clone https://github.com/salendron/hautzenbergerat.git

cd $WEBSITEFOLDER
hugo

lftp -f "
open $HOST
user $USER $PASS
lcd $SOURCEFOLDER
mirror --reverse --delete --verbose $SOURCEFOLDER $TARGETFOLDER
bye
"

rm -rf $BUILDROOTFOLDER