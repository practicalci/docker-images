#!/bin/bash -il

set -exo pipefail

# add to conda base devel tools no in the native image
source /opt/conda/etc/profile.d/conda.sh
conda activate

# install C++ development tools
# pyyaml is required by run-clang-tidy.py command
conda install --yes --quiet \
  pyyaml              \
  cmake=3.13          \
  ninja=1.9           \
  gcovr=4.1

conda clean -tipy
conda build purge-all
chgrp -R lucky /opt/conda && chmod -R g=u /opt/conda
