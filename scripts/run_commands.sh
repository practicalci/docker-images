#!/bin/bash -il

set -exo pipefail

export additional_channel=""

if [ "$(uname -m)" = "x86_64" ]; then
   export supkg="gosu"
   export condapkg="https://repo.continuum.io/miniconda/Miniconda3-4.5.11-Linux-x86_64.sh"
   export conda_chksum="e1045ee415162f944b6aebfe560b8fee"
elif [ "$(uname -m)" = "ppc64le" ]; then
   export supkg="su-exec"
   export condapkg="https://repo.continuum.io/miniconda/Miniconda3-4.5.11-Linux-ppc64le.sh"
   export conda_chksum="4b1ac3b4b70bfa710c9f1c5c6d3f3166"
elif [ "$(uname -m)" = "aarch64" ]; then
   export supkg="su-exec"
   export condapkg="https://github.com/jjhelmus/conda4aarch64/releases/download/1.0.0/c4aarch64_installer-1.0.0-Linux-aarch64.sh"
   export conda_chksum="7f6f3c6ac5895188766218f222feb131"
   # defaults is not enough
   export additional_channel="--add channels c4aarch64"
else
   exit 1
fi

# Install the latest Miniconda with Python 3 and update everything.
curl -s -L $condapkg > miniconda.sh
md5sum miniconda.sh | grep $conda_chksum

bash miniconda.sh -b -p /opt/conda
rm -f miniconda.sh
touch /opt/conda/conda-meta/pinned
ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh
source /opt/conda/etc/profile.d/conda.sh

# Initialize conda in skel
cat << EOF >> /etc/skel/.bashrc
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/conda/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/conda/etc/profile.d/conda.sh" ]; then
        . "/opt/conda/etc/profile.d/conda.sh"
    else
        export PATH="/opt/conda/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
EOF



conda activate
conda config --set show_channel_urls True
conda config ${additional_channel} --add channels conda-forge
conda config --show-sources
conda update --all --yes
conda clean -tipy

# Install conda build and deployment tools.
conda install --yes --quiet conda-build anaconda-client jinja2 setuptools python=3.7
conda clean -tipy

# Install docker tool
conda install --yes $supkg
export CONDA_SUEXEC_INFO=( `conda list $supkg | grep $supkg` )
echo "$supkg ${CONDA_SUEXEC_INFO[1]}" >> /opt/conda/conda-meta/pinned

# verify that the binary works
$supkg nobody true

# Emulate sudo
cat << EOF >> /usr/bin/sudo
#!/bin/sh

# Emulate the sudo command

exec $supkg root:root "\$@"

EOF

chmod +x /usr/bin/sudo

conda install --yes tini
export CONDA_TINI_INFO=( `conda list tini | grep tini` )
echo "tini ${CONDA_TINI_INFO[1]}" >> /opt/conda/conda-meta/pinned
conda clean -tipy
conda build purge-all

# Lucky group gets permission to write in the conda dir
groupadd -g 32766 lucky
chgrp -R lucky /opt/conda && chmod -R g=u /opt/conda
