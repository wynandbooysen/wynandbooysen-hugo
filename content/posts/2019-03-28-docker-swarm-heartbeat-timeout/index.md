---
title: "Docker Swarm Heartbeat"
date: 2019-03-28
draft: false
images: 
  - /images/docker.png
tags: 
  - Swarm
  - Docker
  - VMware
---

The default timeout for the Swarm heartbeat is 5s which is too low when running Docker hosts ontop of VMware with VMotion enabled

Increasing this solves the issue where nodes get marked as unhealthy in the Swarm cluster

Simply run the following command on a Swarm Manager to make the change
```bash
docker swarm update --dispatcher-heartbeat 30s
```
