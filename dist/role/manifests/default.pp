class role::default {
  # Base packages, always installed
  package { [
    'bash-completion',
    'bzip2',
    'curl',
    'dnsutils',
    'dos2unix',
    'emacs',
    'htop',
    'iotop',
    'iptraf',
    'itop',
    'less',
    'lsof',
    'puppet-el',
    'pv',
    'screen',
    'secure-delete',
    'sysstat',
    'telnet',
    ]:
    ensure => present,
  }

  class { 'apt': }

  class { 'logrotate': }

  class { 'ntp': }

  class { 'openssh': }

  class { 'puppet': }

  class { 'puppi': }

  class { 'timezone': }

  class { 'sudo': }

}
