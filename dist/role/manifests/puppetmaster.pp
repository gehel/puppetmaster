class role::puppetmaster inherits role::default {
  apt::conf { 'allow-unauthenticated': content => 'APT::Get::AllowUnauthenticated yes;', }

  class { 'git': }

  class { 'puppetdb':
    http_host => $::fqdn,
    before    => Class['puppet'],
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

  class { 'r10k':
    remote => 'git@github.com:gehel/puppetmaster.git',
  } -> cron { 'r10k-deploy-env':
    command => '/usr/local/bin/r10k deploy environment -p',
    minute  => '*/5',
  }

  class { 'mysql':
  }

  file { '/root/.ssh/id_rsa':
    ensure  => 'present',
    content => hiera('ssh_puppetmaster_root_private_key'),
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
  }

  file { '/root/.ssh/id_rsa.pub':
    ensure => 'present',
    source => 'puppet:///modules/role/puppetmaster/ssh/id_rsa.pub',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

}
