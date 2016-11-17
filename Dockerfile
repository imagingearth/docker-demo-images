# Docker demo image, as used on try.jupyter.org and tmpnb.org

FROM jgomezdans/scipy-notebook

MAINTAINER Jupyter Project <jgomezdans@gmail.com>

USER root
RUN apt-get update \
 && apt-get -y dist-upgrade --no-install-recommends \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN apt-get install unzip wget

# BEGININCLUDE jupyter/datascience-notebook
# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
# FROM jupyter/scipy-notebook

# MAINTAINER Jupyter Project <jupyter@googlegroups.com>


USER $NB_USER


# Extra Kernels
RUN pip install --user --no-cache-dir bash_kernel && \
    python -m bash_kernel.install

# everytime something changes locally

# Add local content, starting with notebooks and datasets which are the largest
# so that later, smaller file changes do not cause a complete recopy during 
# build
COPY notebooks/two_stream/ /home/$NB_USER/work/
#COPY datasets/ /home/$NB_USER/work/datasets/

# Switch back to root for permission fixes, conversions, and trust. Make sure
# trust is done as $NB_USER so that the signing secret winds up in the $NB_USER
# profile, not root's
USER root

# Convert notebooks to the current format and trust them
RUN find /home/$NB_USER/work -name '*.ipynb' -exec jupyter nbconvert --to notebook {} --output {} \; && \
    chown -R $NB_USER:users /home/$NB_USER && \
    sudo -u $NB_USER env "PATH=$PATH" find /home/$NB_USER/work -name '*.ipynb' -exec jupyter trust {} \;

# Finally, add the site specific tmpnb.org / try.jupyter.org configuration.
# These should probably be split off into a separate docker image so that others
# can reuse the very expensive build of all the above with their own site 
# customization.

# Install our custom.js
COPY resources/custom.js /home/$NB_USER/.jupyter/custom/

# Add the templates
COPY resources/templates/ /srv/templates/
RUN chmod a+rX /srv/templates

# Append tmpnb specific options to the base config
COPY resources/jupyter_notebook_config.partial.py /tmp/
RUN cat /tmp/jupyter_notebook_config.partial.py >> /home/$NB_USER/.jupyter/jupyter_notebook_config.py && \
    rm /tmp/jupyter_notebook_config.partial.py
