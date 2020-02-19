# #!/bin/bash

echo "Create docker-host at Google Compute Engine"
docker-machine create --driver google \
    --google-project docker-267016 \
    --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
    --google-machine-type n1-standard-1 \
    --google-disk-size "100" \
    --google-zone us-east1-b \
    docker-host
