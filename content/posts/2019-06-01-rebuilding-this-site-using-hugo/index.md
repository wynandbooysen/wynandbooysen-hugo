---
title: "Rebuilding this site using Hugo"
date: 2019-06-01
draft: false
images: 
  - /images/hugo-logo.png
tags: 
  - Hugo
  - Docker
  - GitHub
  - NGINX
---

🏗 Under Construction 🚧

I'm back to blogging, but this time around I've settled on using Hugo (Go) over Pelican (Python) as my SSG (Static Site Generator) of choice.  SSG output HTML content that can be hosted almost anywhere including but not limited to GitHub Pages, Amazon S3, VPS etc.  I will host this site on a DigitalOcean droplet for now.  You too can try out DigitalOcean with with some free credits by clicking here: https://m.do.co/c/ae32c4293b17 

Hugo is written in Go, thus it consists of a single executable binary.  No more installing multiple dependencies just to render a basic blog.

![xkcd Python Env](https://imgs.xkcd.com/comics/python_environment.png)

Getting started with Hugo is really easy thanks to the great documentation - https://gohugo.io/categories/getting-started

Generate a new site with the following, then change into it's root:

```bash
hugo new site ${SITE_NAME}
cd ${SITE_NAME}
```

add a theme https://themes.gohugo.io/ into the themes directory, edit the config.toml to use that theme and you are ready to fire up your site and start adding content.  Start the development server which will live reload while you are adding your content.

```bash
sudo hugo server -D
```

So now that we have the basics of generating the site let's look at how to publish the site.  As mentioned earlier Hugo will generate HTML output that can be served via any basic web server.  This will be in the 'public' folder after running <b>hugo</b>, but I'll skip that for now

I'll serve it via a Docker container the same way as I did my Pelican blog as well as my HTML only personal landing page after that.  This time however I'll be making use of a multi-stage Dockerfile, which will automatically run Hugo in one container producing the public folder and making it available to copy over into the final container which contains only NGINX

```Dockerfile
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
```

Part 1 of the Dockerfile is the build portion, I use an alpine image to install & build the Hugo contents of my blog

Part 2 of the Dockerfile retreives the 'public' folder's content from the build image and copies it into NGINX site folder, this is the image that I'll use to host the site

It's now ready to get served

I'll talk about the hosting setup in another post