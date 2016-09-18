case $::server_role {
  'puppetmaster' : {
    class { 'role::puppetmaster': }
  }
}

node 'durin.home.ledcom.ch' {
  class { 'role::dev_workstation': }
  file { '/media/music/':
    ensure => directory,
  }
  mount { '/media/music':
    ensure  => mounted,
    device  => 'freenas.home.ledcom.ch:/mnt/main/music',
    fstype    => 'nfs',
    options => "defaults",
    atboot  => true,
  }
}

node 'galadriel.home.ledcom.ch' {
  class { 'role::dev_workstation': }
}

node 'gandalf' {
  class { 'role::dev_workstation': }
}

node 'airpi.home.ledcom.ch' {
  class { 'role::airpi': }
}

node 'gloin.home.ledcom.ch' {
  class { 'role::default': }

  file { '/usr/local/sbin/puppet-standalone.sh':
    ensure  => 'present',
    content => template('role/puppet/puppet-standalone.sh.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0775',
  } ->
  cron { 'puppet-standalone':
    command => '/usr/local/sbin/puppet-standalone.sh',
    special => 'daily',
  }

  class { 'tftp': }

  class { 'pxe': }

  $coreos_version = '1122.2.0'

  pxe::images { 'coreos':
    os   => 'coreos',
    ver  => $coreos_version,
    arch => 'amd64',
  }
  # coreos (192.168.1.40)
  pxe::menu::host { 'C0A80128':
    kernel => "images/coreos/${coreos_version}/amd64/coreos_production_pxe.vmlinuz",
    append => "initrd=images/coreos/${coreos_version}/amd64/coreos_production_pxe_image.cpio.gz root=LABEL=ROOT cloud-config-url=http://pastebin.com/raw.php?i=KPNSF9Xf",
  }
}

node default {
}
