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
  # Hack required due to bug with Augeas not working with empty or non-existent
  # Json file
  exec { "Create ${conf}":
    command => "/bin/echo '{}' > ${conf}",
    creates => $conf,
  } ->
  file { $conf:
    owner => $mattermost::user,
    group => $mattermost::group,
    mode  => '0644',
  } ->
  augeas{ $conf:
    changes => template('mattermost/config.json.erb'),
    lens    => 'Json.lns',
    incl    => $conf,
  }
}