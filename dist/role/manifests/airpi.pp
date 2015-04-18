class role::airpi inherits role::default {

  $puppet_fqdn = 'airpi.home.ledcom.ch'

  Logrotate::Rule {
    rotate       => 4,
    missingok    => true,
    ifempty      => false,
    compress     => true,
    size         => '1M',
    rotate_every => 'day',
  }
  
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

  class { 'fail2ban':
    jails_config   => 'concat',
    banaction      => 'shorewall',
    mailto         => 'guillaume.lederrey@gmail.com',
  }
  fail2ban::jail { 'sshd':
    port     => '22',
    logpath  => '/var/log/auth.log',
    maxretry => '5',
    action   => 'shorewall',
  }
  logrotate::rule { 'fail2ban':
    path       => '/var/log/fail2ban.log',
    postrotate => '/usr/local/bin/fail2ban-client set logtarget /var/log/fail2ban.log >/dev/null',
  }

}
