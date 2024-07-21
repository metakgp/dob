FROM postgres:16

RUN apt-get update && apt-get install -y curl python3 python3-pip gzip

ENV TZ=Asia/Kolkata
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# install supercronic as cron replacement : https://github.com/aptible/supercronic?tab=readme-ov-file#why-supercronic
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.30/supercronic-linux-amd64 \
    SUPERCRONIC=supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=9f27ad28c5c57cd133325b2a66bba69ba2235799

RUN curl -fsSLO "$SUPERCRONIC_URL" \
    && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
    && chmod +x "$SUPERCRONIC" \
    && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
    && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

WORKDIR /root

ARG DBPASSFILE

COPY ./ ./backup
COPY ${DBPASSFILE} ./.pgpass

RUN pip3 install -qr ./backup/requirements.txt --break-system-packages

CMD ["supercronic", "/root/backup/crontab"]
