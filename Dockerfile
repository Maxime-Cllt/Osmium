FROM alpine:3.19.1
LABEL authors="rahman"

RUN apk add ocaml opam

ENTRYPOINT ["tail", "-f", "/dev/null"]