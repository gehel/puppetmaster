# Activate automatic monitoring
$monitor = true
$monitor_tool = [ "nagios" , "puppi" ]

# Activate Automatic firewalling
$firewall = true
$firewall_tool = "iptables"
$firewall_destination = "0/0" # Default is $ip_address
$iptables_block_policy = "accept"

# Activate modules debugging (not too resource intensive and useful)
$debug = false

# Activate Puppi integration in modules
$puppi = true

case $server_role {
  'puppetmaster': { class { 'role::puppetmaster': } }
}

node default {
}

