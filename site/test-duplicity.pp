class { 'apt': force_aptget_update => true, } ->
class { 'duplicity':
  backups => {
    'test-backup' => {
      source_dir => '/home/vagrant',
      target_url => 'scp://gehel@freenas.home.ledcom.ch//mnt/main_volume/backups/tests',
      includes   => ['chef.sh'],
      excludes   => ['ruby.sh'],
    }
  }
}