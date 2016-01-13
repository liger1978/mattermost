# See README.md.
class mattermost (
  $base_url         = $mattermost::params::base_url,
  $filename         = $mattermost::params::filename,
  $version          = $mattermost::params::version,
  $full_url         = $mattermost::params::full_url,
  $dir              = $mattermost::params::dir,
  $symlink          = $mattermost::params::symlink,
  $create_user      = $mattermost::params::create_user,
  $create_group     = $mattermost::params::create_group,
  $user             = $mattermost::params::user,
  $group            = $mattermost::params::group,
  $uid              = $mattermost::params::uid,
  $gid              = $mattermost::params::gid,
  $conf             = $mattermost::params::conf,
  $override_options = $mattermost::params::override_options,
  $manage_data_dir  = $mattermost::params::manage_data_dir,
  $depend_service   = $mattermost::params::depend_service,
  $install_service  = $mattermost::params::install_service,
  $manage_service   = $mattermost::params::manage_service,
  $service_template = $mattermost::params::service_template,
  $service_path     = $mattermost::params::service_path,

) inherits mattermost::params {

  validate_string($base_url)
  validate_string($filename)
  validate_string($version)
  validate_string($full_url)
  validate_absolute_path($dir)
  validate_absolute_path($symlink)
  validate_bool($create_user)
  validate_bool($create_group)
  validate_string($user)
  validate_string($group)
  validate_integer($uid)
  validate_integer($gid)
  validate_hash($override_options)
  validate_bool($manage_data_dir)
  validate_string($depend_service)
  validate_bool($install_service)
  validate_bool($manage_service)
  validate_string($service_template)
  validate_string($service_path)
  if ( $override_options['FileSettings'] ) {
    if ($override_options['FileSettings']['Directory']) {
      $data_dir = $override_options['FileSettings']['Directory']
      validate_absolute_path($data_dir)
    }
    else {
      $data_dir = undef
    }
  }
  else {
    $data_dir = undef
  }

  anchor { 'mattermost::begin': } ->
  class { '::mattermost::install': } ->
  class { '::mattermost::config': } ->
  class { '::mattermost::service': } ->
  anchor { 'mattermost::end': }
}
