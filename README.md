Docker MaaS
----
[![Build Status](https://travis-ci.org/ARTbio/maas-docker.svg?branch=master)](https://travis-ci.org/ARTbio/maas-docker)


This repo contains a Dockerfile and an ansible playbook to build a Docker image
with Canonical's MaaS. The build procedure is a little different from usual Dockerfiles,
because we have to start the container in privileged mode to finish building.

To build the container, type

```
make build
```

This will build a first docker image, then run that image in `--privileged` mode to finish the installation.
To run the image, create a persistent volume:

```
make persistent_data
```

Then start the image

```
make run_persistent
```

If you want to boot pysical nodes with MaaS create a docker network that contains a physical interface.
Assuming your physical network is on the 192.168.1.0/24 subnet, create a new docker network with

```
docker network create -d macvlan \
    --subnet=192.168.1.0/24 \
    --gateway=192.168.1.253  \
    --aux-address="exclude_host=192.168.1.1" \
    -o parent=eth1 \
    net1
```

The network net1 will then show up in the list of docker networks:

```
$ docker network ls
NETWORK ID          NAME                    DRIVER
c93f2f6e09df        bridge                  bridge              
f1013ec4aa62        host                    host                
094a5738492a        net1                    bridge              
a9c220157a01        none                    null                
9ff0cc43cec6        sentrycompose_default   bridge  
```

Now stop the running container and start a new container inside the newly created docker container:
```
make rm # stops and removes container
make run_persistent -e NET=net1
```

You should be able to deploy machines in MaaS now.
