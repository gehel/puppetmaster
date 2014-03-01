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
    'ruby-dev',
    'screen',
    'secure-delete',
    'sysstat',
    'telnet',
    ]:
    ensure => present,
  }

  class { 'apt':
  }

  class { 'logrotate':
  }

  class { 'mcollective':
    require => Package['ruby-dev'],
  }

  class { 'ntp':
  }

  class { 'openssh':
  }

  class { 'puppet':
  }

  class { 'puppi':
  }

  class { 'rundeck::node':
  }

  class { 'sysctl':
  }

  class { 'timezone':
  }

  class { 'sudo':
  }

}