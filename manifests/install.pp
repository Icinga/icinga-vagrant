# == Class: grafana::install
#
# This class downloads and installs grafana.
# SHOULD NOT be called directly.
#
# === Parameters
#
# None.
#
class grafana::install {

  exec {
    'Download Grafana':
      command => "curl -s -L ${::grafana::package_base}/grafana-${::grafana::version}.tar.gz | tar xz",
      cwd     => $::grafana::install_dir,
      creates => "${::grafana::install_dir}/grafana-${::grafana::version}"
  }->
  file {
    "${::grafana::install_dir}/grafana":
      ensure => link,
      target => "${::grafana::install_dir}/grafana-${::grafana::version}"
  }

}
