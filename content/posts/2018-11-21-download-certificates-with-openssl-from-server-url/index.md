---
title: "Download Certificates With OpenSSL From Server URL"
date: 2018-11-21T16:10:57+02:00
draft: false
images: 
  - 
tags: 
  - OpenSSL
  - Talend
---
Sometimes you need to get certificates from a website or API and store them locally

This is especially true for anything using self-signed certificates, which is what I encountered using Talend to extract data from several virtual appliances.

Use the -servername option if Server Name Indication (SNI) is used, e.g multiple SSL hosts behind 1 IP address, to retreive the correct certificate

Get the SSL certificate of a website using openssl command, substitute example.org with the desired URL :
```bash
openssl s_client -connect example.org:443 -servername example.org< /dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > public.crt
```
