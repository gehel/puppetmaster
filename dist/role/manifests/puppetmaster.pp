class role::puppetmaster inherits role::default {
  class { 'puppet':
    mode          => 'server',
    dns_alt_names => 'puppet.aws.ledcom.ch, puppet.int.aws.ledcom.ch',
    manifest_path => '$confdir/environments/$environment/site/site.pp',
    module_path   => '/etc/puppet/environments/$environment/modules:/etc/puppet/environments/$environment/dist',
    db            => 'mysql',
    db_name       => $::puppetmaster_db_name,
    db_server     => $::puppetmaster_db_server,
    db_port       => $::puppetmaster_db_port,
    db_user       => $::puppetmaster_db_user,
    db_password   => $::puppetmaster_db_password,
    server        => 'puppet.int.aws.ledcom.ch',
  }

  file { '/etc/puppet/public_key.pkcs7.pem':
    owner => 'root',
    group => 'root',
    mode  => '644',
  } -> file { '/etc/puppet/private_key.pkcs7.pem':
    owner => 'root',
    group => 'puppet',
    mode  => '640',
  } -> package { 'hiera-eyaml':
    ensure   => 'latest',
    provider => 'gem',
  } -> file { '/etc/puppet/hiera.yaml':
    ensure => 'present',
    source => 'puppet:///modules/role/hiera.yaml',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  package { 'r10k':
    ensure   => 'latest',
    provider => 'gem',
  } -> cron { 'r10k-deploy-env':
    command => '/usr/local/bin/r10k deploy environment -p',
    minute  => '*/5',
  }

  # export additional SSH server keys for hosts not managed by puppet
  @@sshkey { 'freenas.home.ledcom.ch':
    host_aliases => [ 'freenas', 'freenas.home.ledcom.ch', '192.168.1.20' ],
    type         => 'ssh-rsa',
    key          => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCuRsCE6sS2k1RV1D+g337nbEUi9MDWCSicNwQiwIcxxcnJGam8jMXWgFyP7w5SSe0Ml7JpsFSbAtqOf+lGEUf135AS7BVjKzxqBk0Qzr1/fa3tLGjMbqIr3yw0slvHLKCgoKfxRmc37oRIkzcWhF/Q6zCkk641y320dBw4YR6nI2mt2KAcip3wh4FS8d4QoUaEzXP0AWkfY/toO8rOqCOIk0IT2x7aaa7HH36TaVJPCVKqBxAmppN0BYZhPxV+WP/vMblPp5RgZHZjCceSwkN/1DDYuRTSHzvUZzxa+0WjhBVX+pgiUceflBvKwPYCVfVkMvGllgfb5Nhkj0UDuhE/',
    tag          => ['openssh::hostkeys'];
  }

}

