#!/usr/bin/env bash

# This is the entrypoint script for the dockerfile. Executed in the
# container at runtime.

if [[ $# == 0 ]]; then
    # Presumably the image has been run directly, so help the user get
    # started by outputting the dockcross script
    if [[ -n $DEFAULT_DOCKCROSS_IMAGE ]]; then
        head -n 2 /opt/docker/bin/dockcross
        echo "DEFAULT_DOCKCROSS_IMAGE=$DEFAULT_DOCKCROSS_IMAGE"
        tail -n +4 /opt/docker/bin/dockcross |
          sed -e "s@practicalci\/linux\-armv7@${DEFAULT_DOCKCROSS_IMAGE}@g" |
          sed -e "s@practicalci\-linux\-armv7@${DEFAULT_DOCKCROSS_IMAGE//[\/:]/-}@g"
    else
        cat /opt/docker/bin/dockcross
    fi
    exit 0
fi

# If we are running docker natively, we want to create a user in the container
# with the same UID and GID as the user on the host machine, so that any files
# created are owned by that user. Without this they are all owned by root.
# The dockcross script sets the BUILDER_UID and BUILDER_GID vars.
if [[ -n $BUILDER_UID ]] && [[ -n $BUILDER_GID ]]; then

    if [ "$(uname -m)" = "x86_64" ]; then
       export supkg="gosu"
    elif [ "$(uname -m)" = "aarch64" ]; then
       export supkg="su-exec"
    else
       export supkg="su-exec"
    fi

    groupadd -o -g $BUILDER_GID $BUILDER_GROUP 2> /dev/null
    useradd -o -m -g $BUILDER_GID -u $BUILDER_UID $BUILDER_USER 2> /dev/null

    usermod -aG lucky $BUILDER_USER

    export HOME=/home/${BUILDER_USER}
    export PATH=$PATH:$HOME/bin

    shopt -s dotglob

    # if home does not exist, create it if not do not override the files
    cp -R /etc/skel $HOME && (ls -A1 $HOME/skel | xargs -I {} mv -n $HOME/skel/{} $HOME) && rm -Rf $HOME/skel
    cp /root/.condarc $HOME/.condarc

    chown -R $BUILDER_UID:$BUILDER_GID $HOME

    # Source conda, so that conda commands are found
    # for some reason this is broken and not loaded
    . /etc/profile.d/conda.sh

    # Source everything that needs to be.
    . /opt/docker/bin/entrypoint_source

    # Additional updates specific to the image
    if [[ -e /dockcross/pre_exec.sh ]]; then
        /dockcross/pre_exec.sh
    fi

    # Execute project specific pre execution hook
    if [[ -e /work/.dockcross ]]; then
       $supkg $BUILDER_UID:$BUILDER_GID /work/.dockcross
    fi

    # Enable passwordless sudo capabilities for the user
    chown root:$BUILDER_GID $(which $supkg)
    chmod +s $(which $supkg); sync

    # Run the command as the specified user/group.
    exec $supkg $BUILDER_UID "$@"
else
    # Just run the command as root.
    exec "$@"
fi
