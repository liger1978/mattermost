# mattermost

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with mattermost](#setup)
    * [What mattermost affects](#what-mattermost-affects)
    * [Beginning with mattermost](#beginning-with-mattermost)
4. [Usage - Configuration options and additional functionality](#usage)
    * [Upgrading Mattermost](#upgrading-mattermost)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This module installs and configures [Mattermost](http://www.mattermost.org/), the
"alternative to proprietary SaaS messaging". It is compatible with Enterprise
Linux 6 and 7 (RHEL, CentOS, etc.); Debian 7 and 8; Ubuntu 12.04 - 15.10; and
SLES 12.

## Module Description

The Mattermost module does the following:

 - Installs the Mattermost server from a release archive on the web, or an
   alternative download location within your firewall.
 - Installs and configures a daemon (service) for Mattermost in the format
   native to your operating system.
 - Configures Mattermost according to settings you provide (modifies
   Mattermost's `config.json` file).

## Setup

### What mattermost affects

* Installs Mattermost server (defaults to `/opt/mattermost-${version}`).
* Creates a friendly symbolic link to the installation directory (defaults to
  `/opt/mattermost`).
* Creates a Mattermost daemon (service) using your operating system's native
  service provider.
* Sets provided configuration options for Mattermost server.

### Beginning with mattermost

If you have a suitable database installed for Mattermost server to use as a
backend, this is the minimum you need to get Mattermost server working:

```puppet
class { 'mattermost':
  override_options => {
    'SqlSettings' => {
      'DriverName' => 'postgres',
      'DataSource' => "postgres://db_user:db_pass@db_host:db_port/mattermost?sslmode=disable&connect_timeout=10",
    },
  },
}
```

This will install a Mattermost server listening on the default TCP port
(currently 8065).

Here is an example of Mattermost using PostgreSQL as a database and NGINX as a
reverse proxy, all running on the same system (requires
[puppetlabs/postgresql](https://forge.puppetlabs.com/puppetlabs/postgresql) and
[jfryman/nginx](https://forge.puppetlabs.com/jfryman/nginx)):

```puppet
class { 'postgresql::server':
  ipv4acls => ['host all all 127.0.0.1/32 md5'],
}
postgresql::server::db { 'mattermost':
   user     => 'mattermost',
   password => postgresql_password('mattermost', 'mattermost'),
}
postgresql::server::database_grant { 'mattermost':
  privilege => 'ALL',
  db        => 'mattermost',
  role      => 'mattermost',
} ->
class { 'mattermost':
  override_options => {
    'SqlSettings' => {
      'DriverName' => 'postgres',
      'DataSource' => "postgres://mattermost:mattermost@127.0.0.1:5432/mattermost?sslmode=disable&connect_timeout=10",
    },
  },
}
class { 'nginx': }
nginx::resource::upstream { 'mattermost':
  members => [ 'localhost:8065' ],
}
nginx::resource::vhost { 'mattermost':
  server_name         => [ 'myserver.mydomain' ],
  proxy               => 'http://mattermost',
  location_cfg_append => {
    'proxy_http_version'          => '1.1',
    'proxy_set_header Upgrade'    => '$http_upgrade',
    'proxy_set_header Connection' => '"upgrade"',
  },
}
```

With the above code, you should be able to access the Mattermost application at
`http://myserver.mydomain` (or whatever resolvable DNS domain you chose) via
the NGINX reverse proxy listening on port 80.

## Usage

Use `override_options` to change Mattermost's default settings:

```puppet
class { 'mattermost':
  override_options => {
    'ServiceSettings' => {
      'ListenAddress' => ":80",
    },
    'TeamSettings' => {
      'SiteName' => 'BigCorp Collaboration',
    },
    'SqlSettings' => {
      'DriverName' => 'postgres',
      'DataSource' => "postgres://mattermost:mattermost@127.0.0.1:5432/mattermost?sslmode=disable&connect_timeout=10",
    },
    'FileSettings' => {
      'Directory' => '/var/mattermost',
    },
  }
}
```

Store file data, such as file uploads, in a separate directory (recommended):

```puppet
class { 'mattermost':
  override_options => {
    'FileSettings' => {
      'Directory' => '/var/mattermost',
    },
  },
}
```

Install a specific version:

```puppet
class { 'mattermost':
  version => '1.4.0',
}
```

Install a release candidate:

```puppet
class { 'mattermost':
  version => '2.1.1-rc2',
}
```

Download from an internal server:

```puppet
class { 'mattermost':
  version  => '2.1.0',
  full_url => 'http://intranet.bigcorp.com/packages/mattermost.tar.gz',
}
```

### Upgrading Mattermost

The module can elegantly upgrade your Mattermost installation. To upgrade,
just specify the new version when it has been released, for example:

```puppet
class { 'mattermost':
  version => '2.1.0',
}
```

On the next Puppet run, the new version will be downloaded and installed; the
friendly symbolic link will be changed to point at the new installation
directory and the service will be refreshed.

**Note 1:**  The Mattermost application supports sequential upgrades (for
example, from 1.3.0 &rarr; 1.4.0). Do not try to skip versions.

**Note 2:** Always
[backup your data](http://docs.mattermost.com/install/upgrade-guide.html)
before upgrades.

**Note 3:** For a seamless upgrade you should store your file data outside of
the Mattermost installation directory so that your uploaded files are still
accessible after each upgrade. For example:

```puppet
class { 'mattermost':
  override_options => {
    'FileSettings' => {
      'Directory' => '/var/mattermost',
    },
  },
}
```

## Reference

### Classes

#### Public classes

 - `mattermost`: Main class, includes all other classes

#### Private classes

 - `mattermost::install`: Installs the Mattermost server from a web archive and
   optionally installs a daemon (service) for Mattermost in the format native
   to your operating system.
 - `mattermost::config`: Configures Mattermost according to provided settings.
 - `mattermost::service`: Manages the Mattermost daemon.

### Parameters

#### mattermost

##### `base_url`

The base URL to download the Mattermost server release archive. Defaults to
`https://releases.mattermost.com`.

##### `version`

The version of Mattermost server to install. Defaults to `2.1.0`.

##### `file_name`

The filename of the remote Mattermost server release archive.
Defaults to `mattermost-team-${version}-linux-amd64.tar.gz`, so with the
default `version`, this will be `mattermost-team-2.1.0-linux-amd64.tar.gz`.

##### `full_url`

The full URL of the Mattermost server release archive. Defaults to
`${base_url}/${version}/${filename}`, so with the default `base_url`,
`version` and `file_name`, this will be:
`https://releases.mattermost.com/2.1.0/mattermost-team-2.1.0-linux-amd64.tar.gz`.

**Please note:** If you set `full_url` you should also set `version`
to match the version of Mattermost server you are installing.

##### `dir`

The directory to install Mattermost server on your system. Defaults to
`/opt/mattermost-${version}`.

##### `symlink`

The path of the friendly symbolic link to the versioned Mattermost installation
directory. Defaults to `/opt/mattermost`.

##### `conf`

The path to Mattermost's config file. Defaults to `${dir}/config/confg.json`.

##### `create_user`

Should the module create an unprivileged system account that will be used to run
Mattermost server? Defaults to `true`.

##### `create_group`

Should the module create an unprivileged system group that will be used to run
Mattermost server? Defaults to `true`.

##### `user`

The name of the unprivileged system account that will be used to run
Mattermost server. Defaults to `mattermost`.

##### `group`

The name of the unprivileged system group that will be used to run
Mattermost server. Defaults to `mattermost`.

##### `uid`

The uid of the unprivileged system account that will be used to run
Mattermost server. Defaults to `1500`.

##### `gid`

The gid of the unprivileged system group that will be used to run
Mattermost server. Defaults to `1500`.

##### `override_options`

A hash containing overrides to the default settings contained in Mattermost's
[config file](https://github.com/mattermost/platform/blob/master/config/config.json).
Defaults to `{}` (empty hash).

**Note 1:** You should at least specify `SqlSettings`, e.g.:

```puppet
class { 'mattermost':
  override_options => {
    'SqlSettings' => {
      'DriverName' => 'postgres',
      'DataSource' => "postgres://db_user:db_pass@db_host:db_port/mattermost?sslmode=disable&connect_timeout=10",
    },
  },
}
```

**Note 2:** To purge existing settings from the configuration file, use the
[`purge_conf`](#purge_conf) parameter.

###### `override_options['FileSettings']['Directory']`

An element of the `override_options` hash that specifies the Mattermost data
directory. Setting this element will result in the directory being created with
the correct permissions if it does not already exist (unless
[`manage_data_dir`](#manage_data_dir) is `false`).

An absolute path must be specified. Example:

```puppet
class { 'mattermost':
  override_options => {
    'FileSettings' => {
      'Directory' => '/var/mattermost',
    },
  },
}
```

##### `manage_data_dir`

Should the module ensure Mattermost's data directory exists and has the correct
permissions? This parameter only applies if
[`override_options['FileSettings']['Directory']`](#override_optionsfilesettingsdirectory)
is set. Defaults to `true`.

##### `depend_service`

The local service (i.e. database service) that Mattermost server needs to start
when it is installed on the same server as the database backend. Defaults to
`''` (empty string).

##### `install_service`

Should the module install a daemon for Mattermost server appropriate to your
operating system?  Defaults to `true`.

##### `manage_service`

Should the module manage the installed Mattermost server daemon
(`ensure => 'running'` and `enable => true`)? Defaults to `true`.

##### `purge_conf`

Should the module purge existing settings from Mattermost configuration file?
Defaults to `false`.

## Limitations

This module has been tested with Puppet 3 and 4.

This module has been tested on:

* Red Hat Enterprise Linux 6, 7
* CentOS 6, 7
* Oracle Linux 6, 7
* Scientific Linux 6, 7
* Debian 7, 8
* Ubuntu 12.04, 12.10, 13.04, 13.10, 14.04, 14.10, 15.04, 15.10
* SLES 12

## Development

Please send pull requests.
