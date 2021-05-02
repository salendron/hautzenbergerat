FROM ubuntu:21.04
RUN apt-get update
RUN apt-get -y install hugo git lftp

COPY deploy_hautzenbergerat.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/deploy_hautzenbergerat.sh
CMD ["deploy_hautzenbergerat.sh"] 
