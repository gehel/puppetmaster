class { 'shorewall': }

shorewall::interface { 'loc':
  interface => 'eth0',
  options   => 'tcpflags,nosmurfs,routefilter,logmartians',
}