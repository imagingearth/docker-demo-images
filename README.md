Docker Demo Image
=================

## My notes for deploying this as part of a tmpnb server

I forked this repository because I wanted to have a conda 2.7 environment served through `tmpnb`. I probably went down the route of lots of bumps and turns in the road, but it's apparently working well. This repository creates a docker image called `jgomezdans/demo` which is in itself derived from my other `jgomezdans/scipy-notebook` image. The notebook image installs gdal and a number of other things in a python 2.7 environment. I did that on the interactive prompt, so it's reproducibility value is *ahem* limited, but it should possible to move it to some docker file in the future (it's broadly based on the `jupyter/scipy-notebook` image).

The following commands install and get the `tmpnb` server running. Note that the `orchestrate.py` command can get a lot of different options (e.g. to do with culling notebooks and what not). Currently using defaults, but these might be too limited or too generous.



    export TOKEN=$( head -c 30 /dev/urandom | xxd -p )
    docker run --net=host -d -e CONFIGPROXY_AUTH_TOKEN=$TOKEN --name=proxy \
        jupyter/configurable-http-proxy --default-target http://127.0.0.1:9999
    docker run --net=host -d -e CONFIGPROXY_AUTH_TOKEN=$TOKEN \
        -v /var/run/docker.sock:/docker.sock jupyter/tmpnb \
        python orchestrate.py --image='jgomezdans/demo' \
        --command="jupyter notebook --NotebookApp.base_url={base_path} --ip=0.0.0.0 --port {port}"


[![Join the chat at https://gitter.im/jupyter/docker-demo-images](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/jupyter/docker-demo-images?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Herein lies the Dockerfile for [`jupyter/demo`](https://registry.hub.docker.com/u/jupyter/demo/), the container image currently used by [tmpnb.org](https://tmpnb.org)). It inherits from [`jupyter/minimal-notebook`](https://registry.hub.docker.com/u/jupyter/minimal-notebook/), the base image defined in [`jupyter/docker-stacks`](https://github.com/jupyter/docker-stacks).

Creating sample notebooks does not require knowledge of Docker, just the IPython/Jupyter notebook. Submit PRs against the `notebooks/` folder to get started.

## Organization

The big demo image pulls in resources from:

* `notebooks/` for example notebooks
* `datasets/` for example datasets
* `resources/` for configuration and branding

## Community Notebooks

[tmpnb.org](https://tmpnb.org) is a great resource for communities
looking for a place to host their public IPython/Jupyter notebooks.  If
your group has a notebook you want to share, just fork this repository
and add a directory for your community in the `notebooks/communities` folder
and place your notebook in the new directory
(e.g. `notebooks/communities/north_pole_julia_group/`).  Commit and push
your changes to Github and send us a pull request.

The following tips will make sure your notebooks work well on
[tmpnb.org](https://tmpnb.org) and work well for the users of your
notebook.

* Create your notebook using Jupyter Notebook 4.x to ensure your notebook is `v4` format.
* If adding a notebook that was a slideshow, make sure to set the "Cell Toolbar" setting back to `None`.
* If you are creating your notebook on [tmpnb.org](https://tmpnb.org), make sure you're aware of the 10 minute idle time notebook reaper.  If you walk away from your notebook for too long, you can lose it!

## Building the Docker Image

There is a Makefile to make life a bit easier here:

```
# build it
make build
# try it locally
make dev
```

### Updating the Docker Image

The demo image merges jupyter/datascience-notebook and jupyter/all-spark-notebook.
It does so by inheriting FROM all-spark-notebook and including the contents of its datascience sibling Dockerfiles.
To update the reference tag, edit the TAG variable in the Makefile and run:

    make update-tag


## FAQ

### Can I use the `jupyter/demo` Docker image locally?

Sure. Get a docker setup on your host and then do something like the following.

```
docker pull jupyter/demo
docker run -p 8888:8888 jupyter/demo
```

### Is there a smaller image with fewer languages I can use?

Indeed. See the [docker-stacks](https://github.com/jupyter/docker-stacks) repository for selection of smaller, more focused Docker images.

### When do you update try.jupyter.org / tmpnb.org with new images?

Updates are currently applied ad-hoc, when there's significant demand or new features.

### How do I deploy my own temporary notebook site?

Have a look at [jupyter/tmpnb](https://github.com/jupyter/tmpnb) for the tech that powers the tmpnb.org site and [tmpnb-deploy](https://github.com/jupyter/tmpnb-deploy) for an Ansible playbook used to deploy the site.
