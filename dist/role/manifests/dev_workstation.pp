class role::dev_workstation inherits role::default {

  notice('role: dev_workstation')

  package { [
    'arduino',
    'calibre',
    'chromium-browser',
    'cmus',
    'concordance',
    'congruity',
    'flashplugin-installer',
    'gimp',
    'git-review',
    'gitk',
    'gparted',
    'graphviz',
    'handbrake',
    'icedtea-netx',
    'keepass2',
    'maven2',
    'meld',
    'minicom',
    'mitmproxy',
    'nfs-common',
    'nfs-kernel-server',
    'nmap',
    'nodejs-legacy',
    'npm',
    'openjdk-7-jdk',
    'openjdk-8-jdk',
    'p7zip-full',
    'phantomjs',
    'python-dev',
    'puppet-lint',
    'python-nose',
    'python-pip',
    'python-setuptools',
    'rpm',
    'sound-juicer',
    'sqlitebrowser',
    'sshfs',
    'synergy',
    'tig',
    'unar',
    'virtualbox',
    'virtualenvwrapper',
    'visualvm',
    'wakeonlan',
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

  package { 'hiera-eyaml':
    ensure   => 'present',
    provider => 'gem',
  }
  
  class { 'r10k':
    remote => 'git@github.com:gehel/puppetmaster.git',
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

  #class { 'dropbox': }

  class { 'duplicity': }

  Vcsrepo {
    ensure   => present,
    provider => git,
    user     => 'gehel',
  }
  
  vcsrepo {
    '/home/gehel/dev/puppet/puppetmaster':
      source => 'git@github.com:gehel/puppetmaster.git';
    '/home/gehel/dev/vagrant-vms':
      source => 'git@github.com:gehel/vagrant-vms.git';
    '/home/gehel/dev/utilities/ledcom-parent-pom':
      source => 'git@github.com:gehel/ledcom-parent-pom.git';
    '/home/gehel/dev/utilities/jmx-rmi-agent':
      source => 'git@github.com:gehel/jmx-rmi-agent.git';
    '/home/gehel/dev/jmxtrans':
      source => 'git@github.com:jmxtrans/jmxtrans.git';
    '/home/gehel/dev/jmxtrans2':
      source => 'git@github.com:jmxtrans/jmxtrans2.git';
  }

  class { 'svn':
  }

  package { 'linux-headers-generic': }
  class { 'vagrant': }

  class { 'docker': }

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
    unless  => 'test -d /opt/idea-IU-141.1010.3',
  } -> exec { 'untar-IntelliJ':
    path    => '/usr/bin:/bin',
    command => 'tar xzvf /tmp/ideaIU-14.1.3.tar.gz',
    cwd     => '/opt',
    creates => '/opt/idea-IU-141.1010.3',
  }
  
  #TODO: add PyCharm installation

  # inotify needs to be higher than default for IntelliJ to be happy
  sysctl::value { 'fs.inotify.max_user_watches':
    value => '524288',
  }
  
  # TODO: Source code pro font
  
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
  
  class { 'wmf_workstation':
    user             => 'gehel',
    user_home        => '/home/gehel',
    ssh_priv_key_lab => '~/.ssh/id_rsa_wmf_lab',
  }
  

  # TODO: Docker
  # TODO: DropBox
}
