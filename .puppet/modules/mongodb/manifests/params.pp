# PRIVATE CLASS: do not use directly
class mongodb::params inherits mongodb::globals {
  $ensure                = true
  $dbpath                = '/var/lib/mongodb'
  $bind_ip               = pick($mongodb::globals::bind_ip, ['127.0.0.1'])
  $ipv6                  = undef
  $service_manage        = pick($mongodb::globals::mongod_service_manage, true)
  $service_enable        = pick($mongodb::globals::service_enable, true)
  $service_ensure        = pick($mongodb::globals::service_ensure, 'running')
  $service_status        = $mongodb::globals::service_status
  $restart               = true
  $create_admin          = false
  $admin_username        = 'admin'
  $admin_roles           = [
    'userAdmin', 'readWrite', 'dbAdmin', 'dbAdminAnyDatabase', 'readAnyDatabase',
    'readWriteAnyDatabase', 'userAdminAnyDatabase', 'clusterAdmin',
    'clusterManager', 'clusterMonitor', 'hostManager', 'root', 'restore',
  ]
  $handle_creds          = true
  $store_creds           = false
  $rcfile                = "${::root_home}/.mongorc.js"
  $dbpath_fix            = false

  $manage_package        = pick($mongodb::globals::manage_package, $mongodb::globals::manage_package_repo, false)
  $pidfilemode           = pick($mongodb::globals::pidfilemode, '0644')
  $manage_pidfile        = pick($mongodb::globals::manage_pidfile, true)

  $version               = $mongodb::globals::version

  $config_data           = undef

  if $version {
    $package_ensure        = $version
    $package_ensure_mongos = $version
  } else {
    $package_ensure        = true
    $package_ensure_mongos = true
  }

  # Amazon Linux's OS Family is 'Linux', operating system 'Amazon'.
  case $::osfamily {
    'RedHat', 'Linux', 'Suse': {
      if $manage_package {
        $user                    = pick($mongodb::globals::user, 'mongod')
        $group                   = pick($mongodb::globals::group, 'mongod')
        $server_package_name     = pick($mongodb::globals::server_package_name, "mongodb-${mongodb::globals::edition}-server")
      } else {
        # RedHat/CentOS doesn't come with a prepacked mongodb
        # so we assume that you are using EPEL repository.
        $user                    = pick($mongodb::globals::user, 'mongodb')
        $group                   = pick($mongodb::globals::group, 'mongodb')
        $server_package_name     = pick($mongodb::globals::server_package_name, 'mongodb-server')
      }

      $service_name = pick($mongodb::globals::service_name, 'mongod')
      $logpath      = '/var/log/mongodb/mongod.log'
      $pidfilepath  = '/var/run/mongodb/mongod.pid'
      $config       = '/etc/mongod.conf'
      $fork         = true
      $journal      = true
    }
    'Debian': {
      if $manage_package {
        $service_name            = pick($mongodb::globals::service_name, 'mongod')
        $server_package_name     = pick($mongodb::globals::server_package_name, "mongodb-${mongodb::globals::edition}-server")
        $config                  = '/etc/mongod.conf'
        $pidfilepath             = pick($mongodb::globals::pidfilepath, '/var/run/mongod.pid')
      } else {
        $server_package_name = pick($mongodb::globals::server_package_name, 'mongodb-server')
        $service_name        = pick($mongodb::globals::service_name, 'mongodb')
        $config              = '/etc/mongodb.conf'
        $pidfilepath         = $mongodb::globals::pidfilepath
      }
      $user                    = pick($mongodb::globals::user, 'mongodb')
      $group                   = pick($mongodb::globals::group, 'mongodb')
      $logpath                 = '/var/log/mongodb/mongodb.log'
      # avoid using fork because of the init scripts design
      $fork                    = undef
      $journal                 = undef
    }
    default: {
      fail("Osfamily ${::osfamily} is not supported")
    }
  }
}
