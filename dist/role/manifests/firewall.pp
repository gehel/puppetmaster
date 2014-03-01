class role::firewall inherits role::default {
  file { '/usr/local/sbin/puppet-standalone.sh':
    ensure => 'present',
    source => 'puppet:///modules/role/puppet/puppet-standalone.sh',
    owner  => 'root',
    group  => 'root',
    mode   => '0775',
  } ->
  cron { 'puppet-standalone':
    command => '/usr/local/sbin/puppet-standalone.sh',
    special => 'hourly',
  }

}