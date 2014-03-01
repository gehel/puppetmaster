#!/bin/sh

puppet apply \
  --modulepath=/etc/puppet/environments/production/modules:/etc/puppet/environments/production/dist \
  --hiera_config=/etc/puppet/environments/production/hiera.yaml \
  /etc/puppet/environments/production/site/site.pp