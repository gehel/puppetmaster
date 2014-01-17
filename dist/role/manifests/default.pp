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
    'screen',
    'secure-delete',
    'sysstat',
    'telnet',
    ]:
    ensure => present,
  }

  class { 'logrotate':
  }

  class { 'ntp':
  }

  class { 'openssh':
  }

  class { 'puppet':
  }

  class { 'puppi':
  }

  class { 'timezone':
  }

  class { 'sudo':
  }

}