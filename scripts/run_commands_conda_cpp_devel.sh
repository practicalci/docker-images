#!/bin/bash -il

set -exo pipefail

# add to conda base devel tools no in the native image
source /opt/conda/etc/profile.d/conda.sh
conda activate

# install C++ development tools
conda install --yes --quiet \
  cmake=3.13          \
  ninja=1.9           \

pip install gcovr==4.1

# in ubuntu
if [ -d ~/.cache/pip ]; then rm -rf ~/.cache/pip; fi

conda clean -tipy
conda build purge-all
chgrp -R lucky /opt/conda && chmod -R g=u /opt/conda
