class role::puppetmaster {

  class { 'puppet':
    mode          => 'server',
    server        => 'puppet.ledcom.ch',
    dns_alt_names => 'puppet.ledcom.ch',
    environment   => 'production',
    manifest_path => '$confdir/environments/$environment/site/site.pp',
    module_path   => '/etc/puppet/environments/$environment/modules:/etc/puppet/environments/$environment/dist',
  }

  package { 'hiera-eyaml':
    ensure   => 'latest',
    provider => 'gem',
  } -> file { '/etc/puppet/hiera.yaml':
    ensure => 'present',
    source => 'puppet:///modules/role/hiera.yaml',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  class { 'puppi': }

  package { 'r10k':
    ensure   => 'latest',
    provider => 'gem',
  } -> cron { 'r10k-deploy-env':
    command => '/usr/local/bin/r10k deploy environment -p',
    minute  => '*/5',
  }

}

