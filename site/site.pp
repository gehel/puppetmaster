case $::server_role {
  'puppetmaster' : {
    class { 'role::puppetmaster': }
  }
}

node 'durin.home.ledcom.ch' {
  class { 'role::dev_workstation': }
}

node 'galadriel.home.ledcom.ch' {
  class { 'role::dev_workstation': }
}

node 'gandalf' {
  class { 'role::dev_workstation': }
}

node 'voyage.home.ledcom.ch' {
  class { 'role::firewall': }
}

node 'airpi.home.ledcom.ch' {
  class { 'role::airpi': }
}

node default {
}
