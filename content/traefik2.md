---
title: "Traefik 2 Config"
date: 2021-01-04
draft: false
images: 
  - 
tags: 
  - traefik
  - traefik2
  - docker
  - docker-compose

---

  ## Traefik 2 Config

---
 *Tested against Traefik v.2.3.6*

---
 These are some default configurations I use for my Traefik 2 instances.

 Configuration contains:
 - Global HTTP redirect - supported from v2.2
 - Secure Headers from dynamic_config.yml for HTTPS entrypoint
 - API/Dashboard exposed via the dynamic_config.yml
 - Let's Encrypt HTTP Challenge certificates
 - Docker and File Provider
 - A+ SSL rating for all sites and the dashboard

Secure Headers and TLS options used are from https://ssl-config.mozilla.org so we get A+ SSL rating out-of-the-box


### .env File for Docker compose
---

DOCKERDATADIR is for container persistent storage
DOMAINNAME is for base DOMAIN for services exposed

```
DOCKERDATADIR=/data/containers
DOMAINNAME=example.org
```

### Create Config/Data Files
---

Location for container data is the same as what is defined in the .env file above for DOCKERDATADIR

```
mkdir -p /data/containers/traefik2/{acme,config,log}
mkdir -p /data/docker
touch /data/docker/docker-compose.yml
touch /data/docker/.env
touch /data/containers/traefik2/config/traefik.yml
touch /data/containers/traefik2/config/dynamic_config.yml
touch /data/containers/traefik2/log/traefik.log
touch /data/containers/traefik2/acme/acme.json
chmod 600 /data/containers/traefik2/acme/acme.json
```


### Docker-Compose
---

Location ```/data/docker/docker-compose.yml```

```
version: "3.8"

networks:
  proxy:
    external: true

services:
  #Traefik 2 Reverse Proxy
  traefik:
    image: traefik:v2.3 # Specified version due to watchtower auto-updating
    container_name: traefik
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    networks:
      - proxy
    ports:
      - 80:80
      - 443:443
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - $DOCKERDATADIR/traefik2/config/traefik.yml:/traefik.yml:ro
      - $DOCKERDATADIR/traefik2/log/traefik.log:/traefik.log
      - $DOCKERDATADIR/traefik2/acme:/etc/traefik/acme
      - $DOCKERDATADIR/traefik2/config/dynamic_config.yml:/etc/traefik/dynamic_conf.yml:ro
    labels:
      #enable watchtower to keep Traefik updated automatically
      - "com.centurylinklabs.watchtower.enable=true"
```
     
### Traefik 2 Static Config
---

Location ```/data/containers/traefik2/config/traefik.yml```

```

# Global configuration

#global:
#  checkNewVersion: true
#  sendAnonymousUsage: true


# EntryPoints configuration -v2.2 and higher for global redirect

entryPoints:
  http:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: https
  https:
    address: ":443"
    http:
      middlewares:
        - secureHeaders@file
      tls:
        options: TLSv12@file
        certResolver: le

# API and dashboard configuration

api:
  dashboard: true

# Certificate Resolvers Configuration

certificatesResolvers:
  le:
    acme:
      email: me@example.org
      storage: /etc/traefik/acme/acme.json
      httpChallenge:
        entryPoint: http

# Logs

log:
  filePath: traefik.log
#  format: json
  level: DEBUG


# Providers configuration

providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false
  file:
    filename: /etc/traefik/dynamic_conf.yml
    watch: true

```

### Traefik 2 Dynamic Config


Location ```/data/containers/traefik2/config/dynamic_config.yml```


- If you're using Global HTTP redirect and hosting some on the DOMAINNAME e.g. example.org you can use PathPrefix rule for the Dashboard with middleware to force the trailing slash

- If there is no site directly on example.org HTTP redirect does not hit the dashboard rule, use subdomain then instead e.g. ``` rule: "Host(`traefik.example.org`)" ```

```
http:
  routers:
    dashboard:
      entryPoints:
        - https
      rule: "Host(`example.org`) && (PathPrefix(`/api`) || PathPrefix(`/traefik`))"
      service: api@internal # This is the defined name for api. You cannot change it.
      middlewares:
        - dashauth
        - secureHeaders
        - dashboard-stripprefix
      tls:
        options: TLSv12
        certresolver: le

  middlewares:
    dashauth:
      basicAuth:
        users:
          - "username:password"

    # Dashboard strip prefix with forceSlash: true to force trailing slash on /Dashboard/
    dashboard-stripprefix:
      stripPrefix:
        prefixes:
          - "/traefik"
        forceSlash: true

    secureHeaders:
      headers:
        frameDeny: true
        sslRedirect: true
        browserXssFilter: true
        contentTypeNosniff: true
        forceSTSHeader: true
        stsIncludeSubdomains: true
        stsPreload: true
        stsSeconds: 315360000
        referrerPolicy: "no-referrer"
        customResponseHeaders:
          Strict-Transport-Security: max-age=63072000

# Do not name 'default' it will not get applied when referenced: https://github.com/traefik/traefik/issues/6181
tls:
  options:
    TLSv13:
      minVersion: VersionTLS13
      cipherSuites:
        - TLS_AES_256_GCM_SHA384
        - TLS_CHACHA20_POLY1305_SHA256
      curvePreferences:
        - CurveP521
        - CurveP384
      sniStrict: true
        
    TLSv12:
      minVersion: VersionTLS12
      cipherSuites:
        - TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305
        - TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
      curvePreferences:
        - CurveP521
        - CurveP384
      sniStrict: true

```