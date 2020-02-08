#!/bin/bash
set -e

packer validate -var-file=variables.json reddit-docker-host.json
packer build -var-file=variables.json reddit-docker-host.json
