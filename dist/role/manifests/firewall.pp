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
    'br0':
      ensure => 'absent';
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
      ensure    => 'present',
      family    => 'inet',
      method    => 'static',
      ipaddress => '192.168.1.1',
      netmask   => '255.255.255.0',
      onboot    => 'true';
    'eth2':
      ensure    => 'present',
      family    => 'inet',
      method    => 'static',
      ipaddress => '192.168.3.1',
      netmask   => '255.255.255.0',
      onboot    => 'true';
    'wlan0':
      ensure    => 'present',
      family    => 'inet',
      method    => 'static',
      ipaddress => '192.168.2.1',
      netmask   => '255.255.255.0',
      onboot    => 'true',
      options   => {
        hostapd => '/etc/hostapd/hostapd.wlan0.conf',
      };
  }

  augeas { 'enable_ip_forwarding':
    changes => 'set /files/etc/shorewall/shorewall.conf/IP_FORWARDING Yes',
    lens    => 'Shellvars.lns',
    incl    => '/etc/shorewall/shorewall.conf',
    notify  => Service[shorewall],
  }

  class { 'shorewall': }
  
  shorewall::zone {
    'net':
      type => 'ipv4';
    'loc':
      type => 'ipv4';
    'wifi':
      type => 'ipv4';
    'fon':
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
    'wlan0':
      zone    => 'wifi',
      rfc1918 => true,
      options => 'dhcp,tcpflags,nosmurfs,routefilter,logmartians';
  }

  shorewall::policy {
    'loc-to-net':
      sourcezone      => 'loc',
      destinationzone => 'net',
      policy          => 'ACCEPT',
      order           => 10;
    'wifi-to-net':
      sourcezone      => 'wifi',
      destinationzone => 'net',
      policy          => 'ACCEPT',
      order           => 11;
    'loc-to-wifi':
      sourcezone      => 'loc',
      destinationzone => 'wifi',
      policy          => 'ACCEPT',
      order           => 12;
    'wifi-to-loc':
      sourcezone      => 'wifi',
      destinationzone => 'loc',
      policy          => 'ACCEPT',
      order           => 13;
    'fon-to-net':
      sourcezone      => 'fon',
      destinationzone => 'net',
      policy          => 'ACCEPT',
      order           => 20;
    'fon-to-loc':
      sourcezone      => 'fon',
      destinationzone => 'loc',
      policy          => 'REJECT',
      shloglevel      => 'info',
      order           => 21;
    'fon-to-wifi':
      sourcezone      => 'fon',
      destinationzone => 'wifi',
      policy          => 'REJECT',
      shloglevel      => 'info',
      order           => 22;
    'fw-to-fw':
      sourcezone      => '$FW',
      destinationzone => '$FW',
      policy          => 'ACCEPT',
      order           => 100;
    'fw-to-net':
      sourcezone      => '$FW',
      destinationzone => 'net',
      policy          => 'ACCEPT',
      order           => 110;
    'net-to-fw':
      sourcezone      => 'net',
      destinationzone => '$FW',
      policy          => 'DROP',
      shloglevel      => 'info',
      order           => 998;
    'default':
      sourcezone      => 'all',
      destinationzone => 'all',
      policy          => 'REJECT',
      shloglevel      => 'info',
      order           => 999;
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
    'http-to-fw':
      source      => 'all',
      destination => '$FW',
      action      => 'HTTP(ACCEPT)',
      order       => 2;
    'https-to-fw':
      source      => 'all',
      destination => '$FW',
      action      => 'HTTPS(ACCEPT)',
      order       => 3;
    'ping-hurricane-electric-to-fw':
      source      => 'net:66.220.2.74',
      destination => '$FW',
      action      => 'Ping(ACCEPT)',
      order       => 10;
    'ping-loc-to-fw':
      source      => 'loc',
      destination => '$FW',
      action      => 'Ping(ACCEPT)',
      order       => 11;
    'ping-wifi-to-fw':
      source      => 'wifi',
      destination => '$FW',
      action      => 'Ping(ACCEPT)',
      order       => 12;
    'ping-fon-to-fw':
      source      => 'fon',
      destination => '$FW',
      action      => 'Ping(ACCEPT)',
      order       => 13;
    'dns-loc-to-fw':
      source      => 'loc',
      destination => '$FW',
      action      => 'DNS(ACCEPT)',
      order       => 20;
    'dns-wifi-to-fw':
      source      => 'wifi',
      destination => '$FW',
      action      => 'DNS(ACCEPT)',
      order       => 21;
    'dns-fon-to-fw':
      source      => 'fon',
      destination => '$FW',
      action      => 'DNS(ACCEPT)',
      order       => 22;
    'tftp-loc-to-fw':
      source      => 'loc',
      destination => '$FW',
      action      => 'TFTP(ACCEPT)',
      order       => 30;
    'tftp-wifi-to-fw':
      source      => 'wifi',
      destination => '$FW',
      action      => 'TFTP(ACCEPT)',
      order       => 31;
    'ntp-loc-to-fw':
      source      => 'loc',
      destination => '$FW',
      action      => 'NTP(ACCEPT)',
      order       => 40;
    'ntp-wifi-to-fw':
      source      => 'wifi',
      destination => '$FW',
      action      => 'NTP(ACCEPT)',
      order       => 41;
    'ntp-fon-to-fw':
      source      => 'fon',
      destination => '$FW',
      action      => 'NTP(ACCEPT)',
      order       => 42;
    'graphite-fw-to-loc':
      source          => '$FW',
      destination     => 'loc',
      action          => 'ACCEPT',
      proto           => 'tcp',
      destinationport => '2003',
      order           => 50;
    'graphite-fw-to-wifi':
      source          => '$FW',
      destination     => 'wifi',
      action          => 'ACCEPT',
      proto           => 'tcp',
      destinationport => '2003',
      order           => 51;
  }
  
  class { 'tftp': }
  ->
  class { 'dnsmasq':
    domain    => 'home.ledcom.ch',
    dhcp_boot => 'pxelinux.0,voyage,192.168.1.1',
    tftp_root => $tftp::directory,
  }  

  dnsmasq::dhcp {
    'loc':
      dhcp_start => '192.168.1.100',
      dhcp_end   => '192.168.1.200',
      netmask    => '255.255.255.0',
      lease_time => '24h';
    'wifi':
      dhcp_start => '192.168.2.100',
      dhcp_end   => '192.168.2.200',
      netmask    => '255.255.255.0',
      lease_time => '24h';
    'fon':
      dhcp_start => '192.168.3.100',
      dhcp_end   => '192.168.3.200',
      netmask    => '255.255.255.0',
      lease_time => '24h';
  }

  dnsmasq::dhcpstatic {
    'fon':
      mac => 'c4:71:30:3d:aa:30',
      ip  => '192.168.3.2';
    'freenas':
      mac => '54:04:a6:63:01:15',
      ip  => '192.168.1.20';
    'openelec':
      mac => 'B8:27:EB:C2:1C:11',
      ip  => '192.168.1.30';
    'mediacenter':
      mac => 'e0:cb:4e:b2:98:c7',
      ip  => '192.168.1.40';
    'mediacenter-wifi':
      mac => '00:25:d3:f7:71:be',
      ip  => '192.168.2.40';
    'galadriel':
      mac => 'e4:11:5b:fc:e5:5a',
      ip  => '192.168.1.50';
    'galadriel-wifi':
      mac => '08:11:96:9e:d3:6c',
      ip  => '192.168.2.50';
    'mrg-phone':
      mac => '20:64:32:0a:49:5c',
      ip  => '192.168.2.51';
    'mrg-tablet':
      mac => '08:d4:2b:17:6c:7c',
      ip  => '192.168.2.52';
    'france-macbook':
      mac => '58:b0:35:5c:7f:5c',
      ip  => '192.168.1.60';
    'france-iphone':
      mac => 'f0:f6:1c:3f:0e:c8',
      ip  => '192.168.1.61';
  }

  host {
    'voyage':
      ip           => '192.168.1.1',
      host_aliases => [ 'voyage.home.ledcom.ch', 'fw.home.ledcom.ch' ];
    'fon':
      ip           => '192.168.3.2',
      host_aliases => 'fon.home.ledcom.ch';
    'freenas':
      ip           => '192.168.1.20',
      host_aliases => 'freenas.home.ledcom.ch';
    'openelec':
      ip           => '192.168.1.30',
      host_aliases => 'openelec.home.ledcom.ch';
    'coreos':
      ip           => '192.168.1.40',
      host_aliases => 'coreos.home.ledcom.ch';
    'coreos-wifi':
      ip           => '192.168.2.40',
      host_aliases => 'coreos-wifi.home.ledcom.ch';
    'galadriel':
      ip           => '192.168.1.50',
      host_aliases => 'galadriel.home.ledcom.ch';
    'galadriel-wifi':
      ip           => '192.168.2.50',
      host_aliases => 'galadriel-wifi.home.ledcom.ch';
    'mrg-phone':
      ip           => '192.168.2.51',
      host_aliases => 'mrg-phone.home.ledcom.ch';
    'mrg-tablet':
      ip           => '192.168.2.52',
      host_aliases => 'mrg-tablet.home.ledcom.ch';
    'france-macbook':
      ip           => '192.168.1.60',
      host_aliases => 'france-mackbook.home.ledcom.ch';
    'france-iphone':
      ip           => '192.168.1.61',
      host_aliases => 'france-iphone.home.ledcom.ch';
  }

  class { 'datadog_agent':
    api_key => '6f91f73035983c640628104708038c66',
  }

  class { 'pxe': }
  
  $coreos_version = '607.0.0'
  
  pxe::images { 'coreos':
    os   => 'coreos',
    ver  => $coreos_version,
    arch => 'amd64',
  }
  pxe::menu::host { 'C0A802A6':
    kernel => "images/coreos/${coreos_version}/amd64/coreos_production_pxe.vmlinuz",
    append => "initrd=images/coreos/${coreos_version}/amd64/coreos_production_pxe_image.cpio.gz root=LABEL=ROOT cloud-config-url=http://pastebin.com/raw.php?i=KPNSF9Xf",
  }
  # coreos (192.168.1.40)
  pxe::menu::host { 'C0A80128':
    kernel => "images/coreos/${coreos_version}/amd64/coreos_production_pxe.vmlinuz",
    append => "initrd=images/coreos/${coreos_version}/amd64/coreos_production_pxe_image.cpio.gz root=LABEL=ROOT cloud-config-url=http://pastebin.com/raw.php?i=KPNSF9Xf",
  }
  
  class { 'nginx': }

  file { '/var/www':
    ensure => 'directory',
    owner  => 'nobody',
    group  => 'nogroup',
    mode   => '0755',
  }
  nginx::resource::vhost { 'localhost':
    www_root => '/var/www',
  }
  nginx::resource::location { '/status':
    vhost => 'localhost',
    stub_status => true,
  }

  shorewall::rule { 'grafana-fw-to-loc':
      source          => '$FW',
      destination     => 'loc:192.168.1.40',
      action          => 'ACCEPT',
      proto           => 'tcp',
      destinationport => '3000',
      order           => 100;
  }
  nginx::resource::vhost { 'grafana.home.ledcom.ch':
    proxy => 'http://192.168.1.40:3000',
  }

  shorewall::rule { 'graphiteweb-fw-to-loc':
      source          => '$FW',
      destination     => 'loc:192.168.1.40',
      action          => 'ACCEPT',
      proto           => 'tcp',
      destinationport => '80',
      order           => 101;
  }
  nginx::resource::vhost { 'graphite.home.ledcom.ch':
    proxy => 'http://192.168.1.40:80',
  }

  shorewall::rule { 'sabnzbd-fw-to-loc':
      source          => '$FW',
      destination     => 'loc:192.168.1.2',
      action          => 'ACCEPT',
      proto           => 'tcp',
      destinationport => '8080',
      order           => 102;
  }
  nginx::resource::vhost { 'sabnzbd.home.ledcom.ch':
    proxy                => 'http://192.168.1.2:8080',
    auth_basic           => 'LedCom',
    auth_basic_user_file => '/etc/nginx/htpasswd',
  }

  shorewall::rule { 'couchpotato-fw-to-loc':
      source          => '$FW',
      destination     => 'loc:192.168.1.4',
      action          => 'ACCEPT',
      proto           => 'tcp',
      destinationport => '5050',
      order           => 103;
  }
  nginx::resource::vhost { 'couchpotato.home.ledcom.ch':
    proxy                => 'http://192.168.1.4:5050',
    auth_basic           => 'LedCom',
    auth_basic_user_file => '/etc/nginx/htpasswd',
  }

  shorewall::rule { 'sickbeard-fw-to-loc':
      source          => '$FW',
      destination     => 'loc:192.168.1.5',
      action          => 'ACCEPT',
      proto           => 'tcp',
      destinationport => '8081',
      order           => 104;
  }
  nginx::resource::vhost { 'sickbeard.home.ledcom.ch':
    proxy                => 'http://192.168.1.5:8081',
    auth_basic           => 'LedCom',
    auth_basic_user_file => '/etc/nginx/htpasswd',
  }

  class { 'collectd::plugin::nginx':
    url => 'http://localhost/status',
  }
  class { 'datadog_agent::integrations::nginx':
    instances => [
      { 'nginx_status_url'  => 'http://localhost/status', },
    ],
  }

}
