#!/bin/bash -il

set -exo pipefail

# add to conda base devel tools no in the native image
source /opt/conda/etc/profile.d/conda.sh
conda activate

# install general development tools
conda install --yes --quiet \
  bump2version=0.5.8 \
  cookiecutter=1.6

conda clean -tipy
conda build purge-all
chgrp -R lucky /opt/conda && chmod -R g=u /opt/conda
