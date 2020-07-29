#!/usr/bin/env bash

set -e

deployment=$(bosh ds | grep healthwatch2 | head -1 | awk '{print $1}')
grafana_vm=$(bosh -d "${deployment}" vms | grep grafana | awk '{print $1}');

plugins=(grafana-piechart-panel)

for plugin in "${plugins[@]}"; do
  bosh -d "${deployment}" ssh "${grafana_vm}" -c "sudo /var/vcap/packages/grafana/bin/grafana-cli --pluginsDir /var/vcap/packages/grafana_plugins plugins install ${plugin} && sudo /var/vcap/bosh/bin/monit restart grafana"
done