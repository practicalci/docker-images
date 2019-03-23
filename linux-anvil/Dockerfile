FROM amd64/ubuntu:bionic-20190307

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
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
                   bzip2 \
                   make \
                   patch \
                   tar \
                   ca-certificates \
                   curl \
                   git && \
    apt-get clean -y && \
    apt-get autoremove --purge -y && \
    rm -rf /var/lib/apt/lists/*

# Run common commands
COPY scripts/run_commands                   /opt/docker/bin/run_commands
COPY scripts/install-liquidprompt-binary.sh /opt/docker/bin/install-liquidprompt-binary.sh

RUN /opt/docker/bin/run_commands
RUN /opt/docker/bin/install-liquidprompt-binary.sh

# Add a file for users to source to activate the `conda`
# environment `root` and the devtoolset compiler. Also
# add a file that wraps that for use with the `ENTRYPOINT`.

COPY linux-anvil/entrypoint_source /opt/docker/bin/entrypoint_source
COPY scripts/entrypoint.sh /opt/docker/bin/entrypoint.sh
COPY scripts/dockcross /opt/docker/bin/dockcross

WORKDIR /work

# Ensure that all containers start with tini and the user selected process.
# Activate the `conda` environment `root` and the devtoolset compiler.
# Provide a default command (`bash`), which will start if the user doesn't specify one.
ENTRYPOINT [ "/opt/conda/bin/tini", "--", "/opt/docker/bin/entrypoint.sh" ]
