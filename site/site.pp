case $::server_role {
  'puppetmaster' : {
    class { 'role::puppetmaster': }
  }
}

node 'galadriel.home.ledcom.ch' {
  class { 'role::dev_workstation': }
}

node default {
}
