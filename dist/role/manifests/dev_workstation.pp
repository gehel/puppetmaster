# sudo ln -s /home/gehel/dev/puppet/puppetmaster/hiera.yaml /etc/puppet/
# sudo puppet apply \
#      --modulepath='/home/gehel/dev/puppet/puppetmaster/dist:/home/gehel/dev/puppet/puppetmaster/modules' \
#      -e "include role::dev_workstation"
class role::dev_workstation {
  $monitor = true
  $monitor_tool = ['puppi']
  $puppi = true

  package { [
    'chromium-browser',
    'cmus',
    'dos2unix',
    'emacs',
    'htop',
    'maven2',
    'openjdk-7-jdk',
    'secure-delete',
    'synergy',
    'telnet',
    'unity-tweak-tool',
    'virtualbox',
    'xclip',
    ]:
    ensure => 'present',
  }

  package { ['hiera-eyaml', 'r10k',]:
    ensure   => 'present',
    provider => 'gem',
  }

  class { 'git':
  }

  class { 'openssh':
  }

  class { 'puppi':
  }

  class { 'svn':
  }

  package { 'ruby-dev': ensure => 'present', } -> class { 'vagrant': }

  class { 'cntlm': }

  class { 'ntp': }

  Exec {
    logoutput => 'on_failure', }

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
  file { '/etc/sysctl.d/99-inotify.conf':
    ensure  => 'present',
    content => "fs.inotify.max_user_watches = 524288\n",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
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
}