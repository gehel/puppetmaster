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

  class { 'shorewall': }
  
  shorewall::zone {
    'fon':
      type => 'ipv4';
    'loc':
      type => 'ipv4';
    'net':
      type => 'ipv4';
  }

  shorewall::interface {
    'eth0':
      zone    => 'net',
      rfc1918 => true,
      options => 'dhcp,tcpflags,nosmurfs,routefilter,logmartians';
    'eth1':
      zone    => 'loc',
      rfc1918 => true,
      options => 'dhcp,tcpflags,nosmurfs,routefilter,logmartians';
    'eth2':
      zone    => 'fon',
      rfc1918 => true,
      options => 'dhcp,tcpflags,nosmurfs,routefilter,logmartians';
  }

  shorewall::policy {
    'loc-to-net':
      sourcezone              =>      'loc',
      destinationzone         =>      'net',
      policy                  =>      'ACCEPT',
      order                   =>      10;
    'fw-to-fw':
      sourcezone              =>      '$FW',
      destinationzone         =>      '$FW',
      policy                  =>      'ACCEPT',
      order                   =>      100;
    'fw-to-net':
      sourcezone              =>      '$FW',
      destinationzone         =>      'net',
      policy                  =>      'ACCEPT',
      order                   =>      110;
    'net-to-fw':
      sourcezone              =>      'net',
      destinationzone         =>      '$FW',
      policy                  =>      'DROP',
      shloglevel              =>      'info',
      order                   =>      120;
    'default':
      sourcezone              =>      'all',
      destinationzone         =>      'all',
      policy                  =>      'REJECT',
      shloglevel              =>      'info',
      order                   =>      999;
  } 
}
