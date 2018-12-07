#!/usr/bin/env bash

set -o errexit          # Exit on most errors (see the manual)
set -o errtrace         # Make sure any error trap is inherited
set -o nounset          # Disallow expansion of unset variables
set -o pipefail         # Use last non-zero exit code in a pipeline
#set -o xtrace          # Trace the execution of the script (debug)

# var
source ./build-config.sh .
img_name=$ENV_IMG_VERSION
ctn_name="caddydev"

# remove if runnning
if [ $(docker inspect -f '{{.State.Running}}' ${ctn_name}) = "true" ]; then
  docker rm -f ${ctn_name}
  sleep 1
fi

clear;

# run
docker run -it --rm \
--name ${ctn_name} \
-p 2015:2015 \
-v $(pwd)/srv:/srv \
${img_name}