case $server_role {
  'puppetmaster': { class { 'role::puppetmaster': } }
}

node 'galadriel.home.ledcom.ch' {
  class { 'puppet': }
  class { 'role::dev_workstation': }
}

