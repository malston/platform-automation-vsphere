#!/bin/bash

set -eo pipefail

export INTERNAL_REGISTRY=10.213.249.66

# Download harbor cert from Menu -> Host and Clusters -> Workload-Cluster/Configure/Namespaces/Image Registry to ../harbor-root.crt

# You'll want to update this to reflect your repo's host and port
destination=/etc/docker/certs.d/$INTERNAL_REGISTRY

sudo mkdir -p $destination

# Do this for Linux
# sudo cp ../harbor-root.crt $destination

# Do this for Mac
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ../harbor-root.crt

echo "Restart docker daemon"
