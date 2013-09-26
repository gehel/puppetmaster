class role::puppetmaster {

  class { 'puppet':
    mode          => 'server',
    server        => 'puppet.ledcom.ch',
    dns_alt_names => 'puppet.ledcom.ch',
    environment   => 'production',
    manifest_path => '\$confdir/environments/$environment/site/site.pp',
    module_path   => '/etc/puppet/environments/$environment/modules:/etc/puppet/environments/$environment/dist',
  }

  class { 'puppi': }

  cron { 'r10k-deploy-env':
    command => '/usr/local/bin/r10k deploy environment -p',
    minute  => '*/5',
  }

}

