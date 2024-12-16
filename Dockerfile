FROM ubuntu:24.04

WORKDIR /pg-backup

RUN apt update
RUN apt upgrade -y
RUN apt install -y wget postgresql-client
RUN wget -O /usr/local/bin/b2 https://github.com/Backblaze/B2_Command_Line_Tool/releases/latest/download/b2-linux
RUN chmod +x /usr/local/bin/b2

COPY backup.sh .
RUN chmod +x backup.sh

ENV PATH="$PATH:/pg-backup"

ENTRYPOINT [ "backup.sh" ]