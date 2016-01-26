# See README.md.
class mattermost::config inherits mattermost {
  $override_options = $mattermost::override_options
  $dir = regsubst(
    $mattermost::dir,
    '__VERSION__',
    $mattermost::version
  )
  $conf = regsubst(
    $mattermost::conf,
    '__DIR__',
    $dir
  )
  file { $conf:
    content => '{}',
    owner   => $mattermost::user,
    group   => $mattermost::group,
    mode    => '0644',
    replace => false,
  } ->
  augeas{ $conf:
    changes => template('mattermost/config.json.erb'),
    lens    => 'Json.lns',
    incl    => $conf,
  }
}