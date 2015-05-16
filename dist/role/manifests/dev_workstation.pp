class role::dev_workstation inherits role::default {

  package { [
    'p7zip-full',
    'bitcoin-qt',
    'calibre',
    'chromium-browser',
    'cmus',
    'gimp',
    'gitk',
    'git-svn',
    'gparted',
    'graphviz',
    'keepass2',
    'maven2',
    'meld',
    'mencoder',
    'minicom',
    'nmap',
    'nodejs-legacy',
    'npm',
    'openjdk-7-jdk',
    'phantomjs',
    'python-dev',
    'puppet-lint',
    'python-nose',
    'python-setuptools',
    'pyhton-virtualenv',
    'sound-juicer',
    'sqlitebrowser',
    'sshfs',
    'synergy',
    'virtualbox',
    'virtualenvwrapper',
    'visualvm',
    'wireshark',
    'xchat',
    'xclip',
    'xmlstarlet',
    'xvfb',
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

  package { 'hiera-eyaml':
    ensure   => 'present',
    provider => 'gem',
  }
  
  class { 'r10k':
  }

  class { 'dropbox':
  }

  class { 'duplicity':
  }

  require git

  class { 'svn':
  }

  class { 'vagrant': }

  class { 'cntlm': }

  Exec {
    logoutput => 'on_failure', }
    
  class { 'maven::maven':
    version => '3.0.5',
  }

  exec { 'download-Geppetto':
    path    => '/usr/bin',
    command => 'wget -cv https://downloads.puppetlabs.com/geppetto/4.x/geppetto-linux.gtk.x86_64-4.3.1-R201501182354.zip',
    cwd     => '/tmp',
    timeout => '900',
    creates => '/tmp/geppetto-linux.gtk.x86_64-4.3.1-R201501182354.zip',
    unless  => 'test -d /opt/geppetto',
  } -> exec { 'untar-Geppetto':
    path    => '/usr/bin',
    command => 'unzip /tmp/geppetto-linux.gtk.x86_64-4.3.1-R201501182354.zip',
    cwd     => '/opt',
    creates => '/opt/geppetto',
  }

  exec { 'download-IntelliJ':
    path    => '/usr/bin',
    command => 'wget -cv http://download-ln.jetbrains.com/idea/ideaIU-14.1.3.tar.gz',
    cwd     => '/tmp',
    timeout => '900',
    creates => '/tmp/ideaIU-14.1.3.tar.gz',
    unless  => 'test -d /opt/idea-*',
  } -> exec { 'untar-IntelliJ':
    path    => '/usr/bin:/bin',
    command => 'tar xzvf /tmp/ideaIU-14.1.3.tar.gz',
    cwd     => '/opt',
    creates => '/opt/idea-133.696',
  }
  
  #TODO: add PyCharm installation

  # inotify needs to be higher than default for IntelliJ to be happy
  sysctl::value { 'fs.inotify.max_user_watches':
    value => '524288',
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
  
  # basic dirs
  file { [
    '/home/gehel/dev',
  ]:
    ensure => 'directory',
    owner  => 'gehel',
    group  => 'gehel',
    mode   => '0775',
  }

  # TODO: DropBox
}
