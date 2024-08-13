FROM postgres:16

RUN apt-get update && apt-get install -y curl python3 python3-pip gzip

WORKDIR /backup

COPY ./backup .

RUN pip3 install -qr requirements.txt --break-system-packages