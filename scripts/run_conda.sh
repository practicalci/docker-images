#!/bin/bash -il

set -exo pipefail

# add to conda base devel tools no in the native image
source /opt/conda/etc/profile.d/conda.sh

# install general development tools
conda "$@"

conda clean -tipy
conda build purge-all
chgrp -R lucky /opt/conda && chmod -R g=u /opt/conda
