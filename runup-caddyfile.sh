#!/usr/bin/env bash

set -o errexit          # Exit on most errors (see the manual)
set -o errtrace         # Make sure any error trap is inherited
set -o nounset          # Disallow expansion of unset variables
set -o pipefail         # Use last non-zero exit code in a pipeline
#set -o xtrace          # Trace the execution of the script (debug)

docker rm -f caddytest || true;

docker run -it --rm \
--name caddytest \
-p 2015:2015 \
-v $(pwd)/srv:/srv \
-v $(pwd)/Caddyfile:/etc/Caddyfile \
devmtl/caddyfire:0.11.1-d

# very handy to test your Caddyfile configs locally
