# See README.md.
class mattermost::params {
  $fail_msg =
    "OS ${::operatingsystem} ${::operatingsystemrelease} is not supported"
  $base_url = 'https://github.com/mattermost/platform/releases/download'
  $filename = 'mattermost.tar.gz'
  $version = '1.3.0'
  $full_url = '__PLACEHOLDER__'
  $dir = '/opt/mattermost-__VERSION__'
  $symlink = '/opt/mattermost'
  $create_user = true
  $create_group = true
  $user = 'mattermost'
  $group = 'mattermost'
  $uid = '1500'
  $gid = '1500'
  $override_options = {}
  $manage_data_dir = true
  $depend_service = ''
  $install_service = true
  $manage_service = true
  
  if ($override_options['FileSettings']) {
    notify { "here 1":
      message => 'here 1',
    }
    if ($override_options['FileSettings']['Directory']) {
      notify { "here 2":
        message => 'here 2',
      }
      $data_dir = $override_options['FileSettings']['Directory']
    }
    else {
      notify { "here 3":
        message => 'here 3',
      }
      $data_dir = undef
    }
  }
  else {
    notify { "here 4":
      message => 'here 4',
    }
    $data_dir = undef
  }

  case $::osfamily {
    'RedHat': {
      case $::operatingsystemmajrelease {
        '5','6': {
          $service_template = 'mattermost/sysvinit_el.erb'
          $service_path     = '/etc/init.d/mattermost'
          $service_mode     = '0755'
        }
        '7': {
          $service_template = 'mattermost/systemd.erb'
          $service_path     = '/lib/systemd/system/mattermost.service'
        }
        default: { fail($fail_msg) }
      }
    }
    'Debian': {
      case $::operatingsystem {
        'Debian': {
          case $::operatingsystemmajrelease {
            '6','7': {
              $service_template = 'mattermost/sysvinit_debian.erb'
              $service_path     = '/etc/init.d/mattermost'
              $service_mode     = '0755'
            }
            '8': {
              $service_template = 'mattermost/systemd.erb'
              $service_path     = '/lib/systemd/system/mattermost.service'
            }
            default: { fail($fail_msg) }
          }
        }
        'Ubuntu': {
          case $::operatingsystemmajrelease {
            '12.04', '12.10', '13.04', '13.10', '14.04', '14.10': {
              $service_template = 'mattermost/upstart.erb'
              $service_path     = '/etc/init/mattermost.conf'
              $service_provider = 'upstart'
            }
            '15.04': {
              $service_template = 'mattermost/systemd.erb'
              $service_path     = '/lib/systemd/system/mattermost.service'
              $service_provider = 'systemd'
            }
            default: { fail($fail_msg) }
          }
        }
        default: { fail($fail_msg) }
      }
    }
    'Suse': {
      case $::operatingsystem {
        'SLES': {
          case $::operatingsystemmajrelease {
            '12': {
              $service_template = 'mattermost/systemd.erb'
              $service_path     = '/usr/lib/systemd/system/mattermost.service'
              $service_provider = 'systemd'
            }
            default: { fail($fail_msg) }
          }
        }
        default: { fail($fail_msg) }
      }
    }
    default: { fail($fail_msg) }
  }
}