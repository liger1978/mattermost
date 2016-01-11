# See README.md.
class mattermost::config inherits mattermost {
  $override_options = $mattermost::override_options
  $dir = regsubst(
    $mattermost::dir,
    '__VERSION__',
    $mattermost::version
  )
  $conf = "${dir}/config/config.json"
  augeas{ $conf:
    changes => template('mattermost/config.json.erb'),
    lens    => 'Json.lns',
    incl    => $conf,
  }
}