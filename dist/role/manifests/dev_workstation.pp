class role::dev_workstation {

  notice('role: dev_workstation')

  package { [
    'arduino',
    'calibre',
    'chromium-browser',
    'cmus',
    'dsh',
    'fish',
    'gimp',
    'git-buildpackage',
    'git-review',
    'gitk',
    'gpa',
    'gparted',
    'graphviz',
    'handbrake',
    'hiera-eyaml',
    'icedtea-netx',
    'keepass2',
    'linux-headers-generic',
    'meld',
    'minicom',
    'mitmproxy',
    'nfs-common',
    'nfs-kernel-server',
    'nmap',
    'nodejs-legacy',
    'npm',
    'openjdk-8-jdk',
    'openjdk-8-source',
    'p7zip-full',
    'phantomjs',
    'picocom',
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
    'tmux',
    'unar',
    'virtualbox',
    'virtualenvwrapper',
    'visualvm',
    'wakeonlan',
    'wireshark',
    'xclip',
    'xmlstarlet',
    'xvfb',
  ]:
    ensure => 'present',
  }

  # package { [
  #   'fpm',
  # ]:
  #   ensure   => 'present',
  #   provider => 'gem',
  # }

  file { '/usr/share/X11/xorg.conf.d/50-trackman-marble-mouse.conf':
    content => 'puppet:///modules/role/mouse/trackman-marble-mouse.conf',
    owner => 'root',
    group => 'root',
    mode => '0644',
  }

  file { '/usr/share/X11/xorg.conf.d/50-rat7-mouse.conf':
    content => 'puppet:///modules/role/mouse/rat7-mouse.conf',
    owner => 'root',
    group => 'root',
    mode => '0644',
  }

  class { 'r10k':
    remote   => 'git@github.com:gehel/puppetmaster.git',
    provider => 'gem',
  }

  file { '/usr/local/sbin/puppet-standalone.sh':
    ensure  => 'present',
    content => template('role/puppet/puppet-standalone.sh.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0775',
  }
  # ->
  # cron { 'puppet-standalone':
  #   command => '/usr/local/sbin/puppet-standalone.sh',
  #   special => 'daily',
  # }

  #class { 'dropbox': }

  # class { 'duplicity': }

  Vcsrepo {
    ensure   => present,
    provider => git,
    user     => 'gehel',
  }
  
  # vcsrepo {
  #   '/home/gehel/dev/puppet/puppetmaster':
  #     source => 'git@github.com:gehel/puppetmaster.git';
  #   '/home/gehel/dev/vagrant-vms':
  #     source => 'git@github.com:gehel/vagrant-vms.git';
  #   '/home/gehel/dev/utilities/ledcom-parent-pom':
  #     source => 'git@github.com:gehel/ledcom-parent-pom.git';
  #   '/home/gehel/dev/utilities/jmx-rmi-agent':
  #     source => 'git@github.com:gehel/jmx-rmi-agent.git';
  #   '/home/gehel/dev/jmxtrans':
  #     source => 'git@github.com:jmxtrans/jmxtrans.git';
  #   '/home/gehel/dev/jmxtrans2':
  #     source => 'git@github.com:jmxtrans/jmxtrans2.git';
  # }
  #
  # class { 'vagrant': }
  #
  # class { 'docker': }
  #
  # exec { 'download-Geppetto':
  #   path    => '/usr/bin',
  #   command => 'wget -cv https://downloads.puppetlabs.com/geppetto/4.x/geppetto-linux.gtk.x86_64-4.3.1-R201501182354.zip',
  #   cwd     => '/tmp',
  #   timeout => '900',
  #   creates => '/tmp/geppetto-linux.gtk.x86_64-4.3.1-R201501182354.zip',
  #   unless  => 'test -d /opt/geppetto',
  # } -> exec { 'untar-Geppetto':
  #   path    => '/usr/bin',
  #   command => 'unzip /tmp/geppetto-linux.gtk.x86_64-4.3.1-R201501182354.zip',
  #   cwd     => '/opt',
  #   creates => '/opt/geppetto',
  # }
  #
  # exec { 'download-IntelliJ':
  #   path    => '/usr/bin',
  #   command => 'wget -cv http://download-ln.jetbrains.com/idea/ideaIU-14.1.3.tar.gz',
  #   cwd     => '/tmp',
  #   timeout => '900',
  #   creates => '/tmp/ideaIU-14.1.3.tar.gz',
  #   unless  => 'test -d /opt/idea-IU-141.1010.3',
  # } -> exec { 'untar-IntelliJ':
  #   path    => '/usr/bin:/bin',
  #   command => 'tar xzvf /tmp/ideaIU-14.1.3.tar.gz',
  #   cwd     => '/opt',
  #   creates => '/opt/idea-IU-141.1010.3',
  # }
  
  #TODO: add PyCharm installation

  # inotify needs to be higher than default for IntelliJ to be happy
  # sysctl::value { 'fs.inotify.max_user_watches':
  #   value => '524288',
  # }
  
  # TODO: Source code pro font
  
  # basic dirs
  file { [
    '/home/gehel/dev',
  ]:
    ensure => 'directory',
    owner  => 'gehel',
    group  => 'gehel',
    mode   => '0775',
  }
  
  # class { 'wmf_workstation':
  #   user              => 'gehel',
  #   user_home         => '/home/gehel',
  #   ssh_priv_key_lab  => '~/.ssh/id_rsa_wmf_lab',
  #   ssh_priv_key_prod => '~/.ssh/id_rsa_wmf_prod',
  # }
  

  # TODO: Docker
  # TODO: DropBox


  class { '::apt': }
  class { '::gnupg': }
  class { '::ntp': }
  class { '::ssh': }
  class { '::timezone': }

}
