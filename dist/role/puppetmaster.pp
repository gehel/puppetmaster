class role::puppetmaster {

  class { 'puppet':
    mode          => 'server',
    server        => 'puppet.ledcom.ch',
    dns_alt_names => [ 'puppet.ledcom.ch' ],
    environment   => 'master',
    module_path   => '/etc/puppet/environments/\$environment/modules:/etc/puppet/environments/\$environment/dist',
    externalnodes => true,
  }

}

