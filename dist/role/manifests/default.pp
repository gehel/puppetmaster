class role::default {
  # Base packages, always installed
  package { [
    'ack-grep',
    'bash-completion',
    'bzip2',
    'curl',
    'dnsutils',
    'dos2unix',
    'emacs',
    'hping3',
    'htop',
    'iotop',
    'iptraf',
    'itop',
    'less',
    'lsof',
    'ngrep',
    'puppet-el',
    'pv',
    'pwgen',
    'screen',
    'secure-delete',
    'sysstat',
    'telnet',
    'traceroute',
    'unrar',
    'vim',
    ]:
    ensure => present,
  }

  class { '::apt': }
  class { '::gnupg': }
  class { '::ntp': }
  #class { '::puppet': }
  class { '::ssh': }
  class { '::sudo': }
  class { '::timezone': }

  class { 'collectd':
    purge        => true,
    recurse      => true,
    purge_config => true,
  }
  class { 'collectd::plugin::logfile':
    log_level => 'info',
    log_file => '/var/log/collected.log'
  }
  class { 'collectd::plugin::conntrack': }
  class { 'collectd::plugin::cpu': }
  class { 'collectd::plugin::cpufreq': }
  class { 'collectd::plugin::df':
    fstypes          => [ 'devpts', 'proc', 'udev' ],
    ignoreselected   => true,
    valuespercentage => true,
  }
  class { 'collectd::plugin::disk': }
  class { 'collectd::plugin::entropy': }
  class { 'collectd::plugin::interface': }
  class { 'collectd::plugin::irq': }
  class { 'collectd::plugin::load': }
  class { 'collectd::plugin::memory': }
  class { 'collectd::plugin::ntpd': }
  class { 'collectd::plugin::swap': }
  class { 'collectd::plugin::uptime': }
  class { 'collectd::plugin::users': }
  class { 'collectd::plugin::vmem': }
  collectd::plugin::write_graphite::carbon { 'home':
    graphitehost => '192.168.1.40',
  }

  Logrotate::Rule {
    rotate       => 4,
    missingok    => true,
    ifempty      => false,
    compress     => true,
    size         => '1M',
    rotate_every => 'day',
  }

  logrotate::rule {
    'collectd':
      path => '/var/log/collected.log';
    'kern':
      path => '/var/log/kern.log';
    'messages':
      path => '/var/log/messages';
  }

}
