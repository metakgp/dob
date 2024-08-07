FROM postgres:16

RUN apt-get update && apt-get install -y curl python3 python3-pip gzip

WORKDIR /root

COPY ./backup ./backup

RUN pip3 install -qr ./backup/requirements.txt --break-system-packages