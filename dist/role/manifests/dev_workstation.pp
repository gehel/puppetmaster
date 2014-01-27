class role::dev_workstation inherits role::default {

  package { [
    'chromium-browser',
    'cmus',
    'git-svn',
    'maven2',
    'openjdk-7-jdk',
    'phantomjs',
    'synergy',
    'virtualbox',
    'wireshark',
    'xclip',
    'xmlstarlet',
    ]:
    ensure => 'present',
  }

  if $::lsbdistrelease == '13.04' {
    package { [
      'unity-tweak-tool',
      ]:
      ensure => 'present',
    }
  }

  package { 'hiera-eyaml':
    ensure   => 'present',
    provider => 'gem',
  }
  
  class { 'r10k':
  }

  class { 'duplicity':
  }

  class { 'git':
  }

  class { 'svn':
  }

  class { 'vagrant': }

  class { 'cntlm': }

  Exec {
    logoutput => 'on_failure', }
    
  class { 'maven::maven':
    version => '3.0.5',
  }

  exec { 'download-STS':
    path    => '/usr/bin',
    command => 'wget -cv http://download.springsource.com/release/STS/3.4.0/dist/e4.3/spring-tool-suite-3.4.0.RELEASE-e4.3.1-linux-gtk-x86_64.tar.gz',
    cwd     => '/tmp',
    creates => '/tmp/spring-tool-suite-3.4.0.RELEASE-e4.3.1-linux-gtk-x86_64.tar.gz',
    unless  => 'test -d /opt/springsource/sts-3.4.0.RELEASE',
  } -> exec { 'untar-STS':
    path    => '/bin',
    command => 'tar xzvf /tmp/spring-tool-suite-3.4.0.RELEASE-e4.3.1-linux-gtk-x86_64.tar.gz',
    cwd     => '/opt',
    creates => '/opt/springsource/sts-3.4.0.RELEASE',
  }

  exec { 'download-Geppetto':
    path    => '/usr/bin',
    command => 'wget -cv https://downloads.puppetlabs.com/geppetto/geppetto-linux.gtk.x86_64-3.2.0-R201307041307.zip',
    cwd     => '/tmp',
    creates => '/tmp/geppetto-linux.gtk.x86_64-3.2.0-R201307041307.zip',
    unless  => 'test -d /opt/geppetto',
  } -> exec { 'untar-Geppetto':
    path    => '/usr/bin',
    command => 'unzip /tmp/geppetto-linux.gtk.x86_64-3.2.0-R201307041307.zip',
    cwd     => '/opt',
    creates => '/opt/geppetto',
  }

  exec { 'download-IntelliJ':
    path    => '/usr/bin',
    command => 'wget -cv http://download-ln.jetbrains.com/idea/ideaIU-12.1.6.tar.gz',
    cwd     => '/tmp',
    timeout => '900',
    creates => '/tmp/ideaIU-12.1.6.tar.gz',
    unless  => 'test -d /opt/idea-IU-129.1359',
  } -> exec { 'untar-IntelliJ':
    path    => '/usr/bin:/bin',
    command => 'tar xzvf /tmp/ideaIU-12.1.6.tar.gz',
    cwd     => '/opt',
    creates => '/opt/idea-IU-129.1359',
  }

  # inotify needs to be higher than default for IntelliJ to be happy
  sysctl::value { 'fs.inotify.max_user_watches':
    value => '524288',
  }

  file { '/home/gehel/.homesick':
    ensure => 'directory',
    owner  => 'gehel',
    group  => 'gehel',
  } -> file { '/home/gehel/.homesick/repos':
    ensure => 'directory',
    owner  => 'gehel',
    group  => 'gehel',
  } -> exec { 'checkout-Homeshick':
    path    => '/usr/bin',
    command => 'git clone https://github.com/andsens/homeshick.git /home/gehel/.homesick/repos/homeshick',
    creates => '/home/gehel/.homesick/repos/homeshick',
  }

  # Source code pro font
  file { '/usr/share/fonts/truetype/SourceCodePro':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  } -> exec { 'download-source-code-pro':
    path    => '/usr/bin',
    command => 'wget -cv http://optimate.dl.sourceforge.net/project/sourcecodepro.adobe/SourceCodePro_FontsOnly-1.017.zip',
    cwd     => '/tmp',
    creates => '/tmp/SourceCodePro_FontsOnly-1.017.zip',
    unless  => 'test -f /usr/share/fonts/truetype/SourceCodePro-Regular.ttf',
  } -> exec { 'unzip-source-code-pro':
    path    => '/usr/bin',
    command => 'unzip /tmp/SourceCodePro_FontsOnly-1.017.zip',
    cwd     => '/tmp',
    creates => '/tmp/SourceCodePro_FontsOnly-1.017',
    unless  => 'test -f /usr/share/fonts/truetype/SourceCodePro-Regular.ttf',
  } -> exec { 'deploy-source-code-pro':
    path    => '/usr/bin:/bin',
    command => 'cp /tmp/SourceCodePro_FontsOnly-1.017/TTF/*.ttf /usr/share/fonts/truetype',
    cwd     => '/tmp',
    creates => '/usr/share/fonts/truetype/SourceCodePro-Regular.ttf',
  } ~> exec { 'refresh-font-cache':
    path        => '/usr/bin',
    command     => 'fc-cache',
    refreshonly => true,
  }
  
  cron { 'cleanup-gstreamer':
    command => '/bin/rm /home/gehel/.goutputstream-*',
    user => 'gehel',
    monthday => "*",
  }
  
  # eyaml keys
  file { '/home/gehel/eyaml':
    ensure => 'directory',
    owner  => 'gehel',
    group  => 'gehel',
    mode   => '0775',
  }
  file { '/home/gehel/eyaml/private_key.pkcs7.pem':
    ensure  => 'present',
    content => hiera('eyaml_private_key'),
    owner   => 'gehel',
    group   => 'gehel',
    mode    => '0600',
  }
  file { '/home/gehel/eyaml/public_key.pkcs7.pem':
    ensure => 'present',
    source => 'puppet:///modules/role/eyaml/public_key.pkcs7.pem',
    owner  => 'gehel',
    group  => 'gehel',
    mode   => '0664',
  }

  # SSH keys
  file { '/home/gehel/.ssh/backup':
    ensure  => 'present',
    content => hiera('ssh_gehel_backup_private_key'),    
    owner   => 'gehel',
    group   => 'gehel',
    mode    => '0600',
  }
  file { '/home/gehel/.ssh/backup.pub':
    ensure => 'present',
    source => 'puppet:///modules/role/gehel/ssh/backup.pub',
    owner  => 'gehel',
    group  => 'gehel',
    mode   => '0600',
  }
  file { '/home/gehel/.ssh/id_dsa':
    ensure  => 'present',
    content => hiera('ssh_gehel_private_key'),    
    owner   => 'gehel',
    group   => 'gehel',
    mode    => '0600',
  }
  file { '/home/gehel/.ssh/id_dsa.pub':
    ensure => 'present',
    source => 'puppet:///modules/role/gehel/ssh/id_dsa.pub',
    owner  => 'gehel',
    group  => 'gehel',
    mode   => '0600',
  }
  
  # basic dirs
  file { [
    '/home/gehel/dev',
    '/home/gehel/dev/aws',
    '/home/gehel/dev/JavaDojo',    
    '/home/gehel/dev/puppet',
    '/home/gehel/dev/utilities',
  ]:
    ensure => 'directory',
    owner  => 'gehel',
    group  => 'gehel',
    mode   => '0775',
  }

}
