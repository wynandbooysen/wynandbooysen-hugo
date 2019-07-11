---
title: "Portainer Standalone Server: Managing Multiple Swarm Clusters"
date: 2019-07-11
draft: false
images: 
  - /images/docker.png
tags: 
  - Docker
  - Swarm
  - Portainer
---

Portainer is a simple and light UI for Docker management.  Mostly run as a Docker container itself, today however we'll look at running the binary on a standard run of the mill VM without Docker.  We'll make use of the portainer-agents on multiple swarm clusters and add each Endpoint the standalone Portainer host.

On the VM run the following commands to install Portainer's latest binary (update the version number as appropriate)

```bash
cd /opt
wget https://github.com/portainer/portainer/releases/download/1.21.0/portainer-1.21.˓→0-linux-amd64.tar.gz
tar xvpfz portainer-1.21.0-linux-amd64.tar.gz
```

After that ```cd /opt/portainer``` directory and execute

```bash
./portainer --template-file "${PWD}/templates.json"
```

which will run the server live importing templates and setup the DB along with prompting for the admin user to be created by default, CTRL + C to exit.  For quick testing purposes this would be fine, but I'd rather not have to manually start this everytime.  Using Systemd setup an portainer.service to execute the binary with the templates parameter

```bash
WorkingDirectory=/opt/portainer/
ExecStart=/opt/portainer/portainer --template-file templates.json
```

portainer defaults to ```/data``` for it's persistant storage so I'll just add my service file there to make backing up configurations that much easier for myself followed by ```systemctl enable /data/portainer.service``` then ```systemctl start portainer```

Portainer should now be up and running on your VM on port 9000.  Now we just need some endpoints.

Quick and dirty Docker service deployment using:

```bash
docker service create     --name portainer_agent     --network portainer_agent_network     --publish mode=host,target=9001,published=9001     -e AGENT_CLUSTER_ADDR=tasks.portainer_agent     --mode global     --mount type=bind,src=//var/run/docker.sock,dst=/var/run/docker.sock     --mount type=bind,src=//var/lib/docker/volumes,dst=/var/lib/docker/volumes     portainer/agent
```

Will give us working Agent Endpoints to which you can connect to :-)

