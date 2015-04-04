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

  network_config {
    'lo':
      ensure  => 'present',
      family  => 'inet',
      method  => 'loopback',
      onboot  => 'true';
    'eth0':
      ensure  => 'present',
      family  => 'inet',
      method  => 'dhcp',
      onboot  => 'true';
    'eth1':
      ensure  => 'present',
      family  => 'inet',
      method  => 'manual',
      onboot  => 'true';
    'wlan0':
      ensure  => 'present',
      family  => 'inet',
      method  => 'manual',
      onboot  => 'true',
      options => {
        hostapd => '/etc/hostapd/hostapd.wlan0.conf',
      };
    'br0':
      ensure    => 'present',
      family    => 'inet',
      method    => 'static',
      ipaddress => '192.168.1.1',
      netmask   => '255.255.255.0',
      onboot    => 'true',
      options   => {
        bridge-ports => 'eth1, wlan0',
      };
    'eth2':
      ensure    => 'present',
      family    => 'inet',
      method    => 'static',
      ipaddress => '192.168.2.1',
      netmask   => '255.255.255.0',
      onboot    => 'true';
  }

#  class { 'hostapd':
#    ssid           => 'LEDCOM',
#    interface      => 'wlan0',
#    bridge         => 'br0',
#    driver         => 'nl80211',
#    channel        => 9,
#    hw_mode        => 'g',
#    wpa            => '2',
#    wpa_passphrase => '88BD12F633',
#    wpa_key_mgmt   => 'WPA-PSK',
#    wpa_pairwise   => 'TKIP',
#    rsn_pairwise   => 'CCMP',
#  }

  augeas { 'enable_ip_forwarding':
    changes => 'set /files/etc/shorewall/shorewall.conf/IP_FORWARDING Yes',
    lens    => 'Shellvars.lns',
    incl    => '/etc/shorewall/shorewall.conf',
    notify  => Service[shorewall],
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
    'br0':
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
    'fon-to-net':
      sourcezone              =>      'fon',
      destinationzone         =>      'net',
      policy                  =>      'ACCEPT',
      order                   =>      20;
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

  shorewall::masq { 'NAT-to-internet':
    interface => 'eth0',
    source    => '192.168.0.0/16',
  }

  shorewall::rule {
    'ssh-to-fw':
      source      => 'all',
      destination => '$FW',
      action      => 'SSH(ACCEPT)',
      order       => 1;
    'ping-loc-to-fw':
      source      => 'loc',
      destination => '$FW',
      action      => 'Ping(ACCEPT)',
      order       => 2;
    'ping-fon-to-fw':
      source      => 'fon',
      destination => '$FW',
      action      => 'Ping(ACCEPT)',
      order       => 3;
    'dns-loc-to-fw':
      source      => 'loc',
      destination => '$FW',
      action      => 'DNS(ACCEPT)',
      order       => 4;
    'dns-fon-to-fw':
      source      => 'fon',
      destination => '$FW',
      action      => 'DNS(ACCEPT)',
      order       => 5;
  }
  
  class { 'dnsmasq':
    domain            => 'home.ledcom.ch',
  }  

  dnsmasq::dhcp { 'br0':
    dhcp_start => '192.168.1.100',
    dhcp_end   => '192.168.1.200',
    netmask    => '255.255.255.0',
    lease_time => '24h'
  }

  dnsmasq::dhcp { 'fon':
    dhcp_start => '192.168.2.100',
    dhcp_end   => '192.168.2.200',
    netmask    => '255.255.255.0',
    lease_time => '24h'
  }

  dnsmasq::dhcpstatic {
    'host20':
      mac => '54:04:a6:63:01:15',
      ip  => '192.168.1.20';
    'host30':
      mac => 'B8:27:EB:C2:1C:11',
      ip  => '192.168.1.30';
    'host40':
      mac => 'e0:cb:4e:b2:98:c7',
      ip  => '192.168.1.40';
    'host41':
      mac => '00:25:d3:f7:71:be',
      ip  => '192.168.1.41';
    'host50':
      mac => 'e4:11:5b:fc:e5:5a',
      ip  => '192.168.1.50';
    'host51':
      mac => '08:11:96:9e:d3:6c',
    ip  => '192.168.1.51';
  }
}
