#!/bin/bash

function dump() {
    echo "$(date) Dumping certificates"

    traefik-certs-dumper file --version ${TRAEFIK_VERSION:-v1} --crt-name "cert" --crt-ext ".pem" --key-name "key" --key-ext ".pem" --domain-subdir --dest /tmp/work --source /traefik/acme.json >/dev/null          mkdir -p /tmp/work/new_cert

    # PEM
    cat /tmp/work/${DOMAIN}/cert.pem > /tmp/work/new_cert/cert.pem && \
    cat /tmp/work/${DOMAIN2}/cert.pem >> /tmp/work/new_cert/cert.pem && \
    # Key
    cat /tmp/work/${DOMAIN}/key.pem > /tmp/work/new_cert/key.pem && \
    cat /tmp/work/${DOMAIN2}/key.pem >> /tmp/work/new_cert/key.pem

    if [ -f /tmp/work/new_cert/cert.pem ] && [ -f /tmp/work/new_cert/key.pem ] && [ -f /output/cert.pem ] && [ -f /output/key.pem ] && \
        diff -q /tmp/work/new_cert/cert.pem /output/cert.pem >/dev/null && \
        diff -q /tmp/work/new_cert/key.pem /output/key.pem >/dev/null ; \
    then
        echo "$(date) Certificate and key still up to date, doing nothing"
    else
        echo "$(date) Certificate or key differ, updating"
        mv /tmp/work/new_cert/*.pem /output/
    fi
}

mkdir -p /tmp/work
dump

while true; do
    inotifywait -qq -e modify /traefik/acme.json
    dump
done