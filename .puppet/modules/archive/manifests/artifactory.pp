# Define: archive::artifactory
# ============================
#
# archive wrapper for downloading files from artifactory
#
# Parameters
# ----------
#
# * path: fully qualified filepath for the download the file or use archive_path and only supply filename. (namevar).
# * ensure: ensure the file is present/absent.
# * url: artifactory download URL.
# * owner: file owner (see archive params for defaults).
# * group: file group (see archive params for defaults).
# * mode: file mode (see archive params for defaults).
# * archive_path: the parent directory of local filepath.
# * extract: whether to extract the files (true/false).
# * creates: the file created when the archive is extracted (true/false).
# * cleanup: remove archive file after file extraction (true/false).
#
# Examples
# --------
#
# archive::artifactory { '/tmp/logo.png':
#   url   => 'https://repo.jfrog.org/artifactory/distributions/images/Artifactory_120x75.png',
#   owner => 'root',
#   group => 'root',
#   mode  => '0644',
# }
#
# $dirname = 'gradle-1.0-milestone-4-20110723151213+0300'
# $filename = "${dirname}-bin.zip"
#
# archive::artifactory { $filename:
#   archive_path => '/tmp',
#   url          => "http://repo.jfrog.org/artifactory/distributions/org/gradle/${filename}",
#   extract      => true,
#   extract_path => '/opt',
#   creates      => "/opt/${dirname}",
#   cleanup      => true,
# }
#
define archive::artifactory (
  Stdlib::HTTPUrl                $url,
  String                         $path         = $name,
  Enum['present', 'absent']      $ensure       = present,
  Optional[String]               $owner        = undef,
  Optional[String]               $group        = undef,
  Optional[String]               $mode         = undef,
  Optional[Boolean]              $extract      = undef,
  Optional[String]               $extract_path = undef,
  Optional[String]               $creates      = undef,
  Optional[Boolean]              $cleanup      = undef,
  Optional[Stdlib::Absolutepath] $archive_path = undef,
) {

  include archive::params

  if $archive_path {
    $file_path = "${archive_path}/${name}"
  } else {
    $file_path = $path
  }

  assert_type(Stdlib::Absolutepath, $file_path) |$expected, $actual| {
    fail("archive::artifactory[${name}]: \$name or \$archive_path must be '${expected}', not '${actual}'")
  }

  $maven2_data = archive::parse_artifactory_url($url)
  if $maven2_data and $maven2_data['folder_iteg_rev'] == 'SNAPSHOT'{
    # URL represents a SNAPSHOT version. eg 'http://artifactory.example.com/artifactory/repo/com/example/artifact/0.0.1-SNAPSHOT/artifact-0.0.1-SNAPSHOT.zip'
    # Only Artifactory Pro lets you download this directly but the corresponding fileinfo endpoint (where the sha1 checksum is published) doesn't exist.
    # This means we can't use the artifactory_sha1 function

    $latest_url_data = archive::artifactory_latest_url($url, $maven2_data)

    $file_url = $latest_url_data['url']
    $sha1     = $latest_url_data['sha1']
  } else {
    $file_url = $url
    $sha1     = archive::artifactory_checksum($url,'sha1')
  }

  archive { $file_path:
    ensure        => $ensure,
    path          => $file_path,
    extract       => $extract,
    extract_path  => $extract_path,
    source        => $file_url,
    checksum      => $sha1,
    checksum_type => 'sha1',
    creates       => $creates,
    cleanup       => $cleanup,
  }

  $file_owner = pick($owner, $archive::params::owner)
  $file_group = pick($group, $archive::params::group)
  $file_mode  = pick($mode, $archive::params::mode)

  file { $file_path:
    owner   => $file_owner,
    group   => $file_group,
    mode    => $file_mode,
    require => Archive[$file_path],
  }
}
