FROM ppc64le/ubuntu:bionic-20190307

LABEL maintainer="Mario Costa <mario.silva.costa@gmail.com>"

# Set an encoding to make things work smoothly.
ENV LANG en_US.UTF-8

# Add a timestamp for the build. Also, bust the cache.
ADD http://worldclockapi.com/api/json/utc/now /opt/docker/etc/timestamp

# Do not prompt for configuration update
# https://askubuntu.com/a/104912
RUN echo -e \
"Dpkg::Options {\n\
   \"--force-confdef\";\n\
   \"--force-confold\";\n\
}\n" > /etc/apt/apt.conf.d/local

# Install basic requirements.
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
                   bzip2 \
                   make \
                   patch \
                   tar \
                   curl && \
    apt-get clean -y && \
    apt-get autoremove --purge -y && \
    rm -rf /var/lib/apt/lists/*

# Run common commands
COPY scripts/run_commands /opt/docker/bin/run_commands
RUN /opt/docker/bin/run_commands

# Add a file for users to source to activate the `conda`
# environment `root`. Also add a file that wraps that for
# use with the `ENTRYPOINT`.
COPY linux-anvil-ppc64le/entrypoint_source /opt/docker/bin/entrypoint_source
COPY scripts/entrypoint /opt/docker/bin/entrypoint

# Ensure that all containers start with tini and the user selected process.
# Activate the `conda` environment `root`.
# Provide a default command (`bash`), which will start if the user doesn't specify one.
ENTRYPOINT [ "/opt/conda/bin/tini", "--", "/opt/docker/bin/entrypoint" ]
CMD [ "/bin/bash" ]
