$monitor = true
$monitor_tool = ['puppi']
$puppi = true

class { 'puppi': }

class { 'timezone': timezone => 'Europe/Zurich', }

package { 'htop': }

apt::conf { 'allow-unauthenticated': content => 'APT::Get::AllowUnauthenticated yes;', }
class { 'apt': force_aptget_update => true, } ->
class { 'rundeck':
  manage_repos => true,
  projects     => {
    'puppetmaster' => {
      'jobs' => {
        'deploy-puppet-modules' => {
          description         => 'Deploy puppet modules via r10k',
          command_exec        => '/usr/local/bin/r10k deploy environment -p',
          command_description => 'r10k deploy',
          filter              => 'puppetmaster',
          format              => 'yaml',
        }
      }
    }
  }
  ,
}

class { 'rundeck::node':
  attributes => {
    'server_role' => 'puppetmaster'
  }
}