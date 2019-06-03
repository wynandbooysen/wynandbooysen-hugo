
FROM alpine:3.9 as build

ENV HUGO_VERSION 0.55.6
ENV HUGO_BINARY hugo_${HUGO_VERSION}_Linux-64bit.tar.gz

# Install Hugo
RUN set -x && \
  apk add --update wget ca-certificates && \
  wget https://github.com/spf13/hugo/releases/download/v${HUGO_VERSION}/${HUGO_BINARY} && \
  tar xzf ${HUGO_BINARY} && \
  rm -r ${HUGO_BINARY} && \
  mv hugo /usr/bin && \
  apk del wget ca-certificates && \
  rm /var/cache/apk/*

COPY ./ /site

WORKDIR /site

RUN /usr/bin/hugo


FROM nginx:alpine

LABEL maintainer Wynand Booysen  <me@wynandbooysen.com>

COPY ./nginx/default.conf /etc/nginx/conf.d/default.conf

COPY --from=build /site/public /var/www/site


WORKDIR /var/www/site


