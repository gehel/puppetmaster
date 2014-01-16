class role::puppetmaster inherits role::default {
  class { 'puppetdb':
    http_host             => $::fqdn,
    before                => Class['puppet'],
  }

  class { 'puppet':
    mode          => 'server',
    dns_alt_names => 'puppet.aws.ledcom.ch, puppet.int.aws.ledcom.ch',
    manifest_path => '$confdir/environments/$environment/site/site.pp',
    module_path   => '/etc/puppet/environments/$environment/modules:/etc/puppet/environments/$environment/dist',
    db            => 'puppetdb',
    server        => 'puppet.int.aws.ledcom.ch',
    passenger     => true,
  }

  file { '/etc/puppet/public_key.pkcs7.pem':
    owner => 'root',
    group => 'root',
    mode  => '644',
  } -> file { '/etc/puppet/private_key.pkcs7.pem':
    owner => 'root',
    group => 'puppet',
    mode  => '640',
  } -> package { 'hiera-eyaml':
    ensure   => 'latest',
    provider => 'gem',
  } -> file { '/etc/puppet/hiera.yaml':
    ensure => 'link',
    target => '/etc/puppet/environments/production/hiera.yaml',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  package { 'r10k':
    ensure   => 'latest',
    provider => 'gem',
  } -> cron { 'r10k-deploy-env':
    command => '/usr/local/bin/r10k deploy environment -p',
    minute  => '*/5',
  }

}

