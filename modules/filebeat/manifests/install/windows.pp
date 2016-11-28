class filebeat::install::windows {
  $filename = regsubst($filebeat::download_url, '^https.*\/([^\/]+)\.[^.].*', '\1')
  $foldername = 'Filebeat'

  file { $filebeat::install_dir:
    ensure => directory
  }

  remote_file {"${filebeat::tmp_dir}/${filename}.zip":
    ensure      => present,
    source      => $filebeat::download_url,
    verify_peer => false,
  }

  exec { "unzip ${filename}":
    command  => "\$sh=New-Object -COM Shell.Application;\$sh.namespace((Convert-Path '${filebeat::install_dir}')).Copyhere(\$sh.namespace((Convert-Path '${filebeat::tmp_dir}/${filename}.zip')).items(), 16)",
    creates  => "${filebeat::install_dir}/Filebeat",
    provider => powershell,
    require  => [
      File[$filebeat::install_dir],
      Remote_file["${filebeat::tmp_dir}/${filename}.zip"],
    ],
  }

  exec { 'rename folder':
    command  => "Rename-Item '${filebeat::install_dir}/${filename}' Filebeat",
    creates  => "${filebeat::install_dir}/Filebeat",
    provider => powershell,
    require  => Exec["unzip ${filename}"],
  }

  exec { "install ${filename}":
    cwd      => "${filebeat::install_dir}/Filebeat",
    command  => './install-service-filebeat.ps1',
    onlyif   => 'if(Get-WmiObject -Class Win32_Service -Filter "Name=\'filebeat\'") { exit 1 } else {exit 0 }',
    provider =>  powershell,
    require  => Exec['rename folder'],
  }
}
