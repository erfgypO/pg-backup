FROM ubuntu:24.04

WORKDIR /pg-backup

RUN apt update
RUN apt install -y curl gnupg lsb-release

RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
RUN apt update
RUN apt upgrade -y
RUN apt install -y wget postgresql-client-17 python3 python3-pip
RUN pip3 install --break-system-packages b2

COPY backup.sh .
RUN chmod +x backup.sh

ENV PATH="$PATH:/pg-backup"

ENTRYPOINT [ "backup.sh" ]