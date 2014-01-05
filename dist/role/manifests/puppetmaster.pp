class role::puppetmaster inherits role::default {

  class { 'puppet':
    mode          => 'server',
    dns_alt_names => 'puppet.aws.ledcom.ch',
    manifest_path => '$confdir/environments/$environment/site/site.pp',
    module_path   => '/etc/puppet/environments/$environment/modules:/etc/puppet/environments/$environment/dist',
    db            => 'mysql',
    db_name       => $::puppetmaster_db_name,
    db_server     => $::puppetmaster_db_server,
    db_port       => $::puppetmaster_db_port,
    db_user       => $::puppetmaster_db_user,
    db_password   => $::puppetmaster_db_password,
    server        => $fqdn,
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
    ensure => 'present',
    source => 'puppet:///modules/role/hiera.yaml',
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

