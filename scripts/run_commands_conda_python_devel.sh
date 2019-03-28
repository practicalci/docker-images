#!/bin/bash -il

set -exo pipefail

# add to conda base devel tools no in the native image
source /opt/conda/etc/profile.d/conda.sh
conda activate

# install general development tools
conda install --yes --quiet \
  scikit-build=0.8  \
  flake8=3.7        \
  coverage=4.5      \
  pytest            \
  pytest-cov        \
  pytest-xdist

conda clean -tipy
conda build purge-all
chgrp -R lucky /opt/conda && chmod -R g=u /opt/conda
