# This installs Ops Manager. See README.md for more info.

class mongodb::opsmanager (
  String[1] $user                                = $mongodb::opsmanager::params::user,
  String[1] $group                               = $mongodb::opsmanager::params::group,
  Enum['running', 'stopped'] $ensure             = $mongodb::opsmanager::params::ensure,
  String[1] $package_name                        = $mongodb::opsmanager::params::package_name,
  String[1] $package_ensure                      = $mongodb::opsmanager::params::package_ensure,
  Boolean $service_enable                        = $mongodb::opsmanager::params::service_enable,
  Boolean $service_manage                        = $mongodb::opsmanager::params::service_manage,
  String[1] $service_name                        = $mongodb::opsmanager::params::service_name,
  Stdlib::Httpurl $download_url                  = $mongodb::opsmanager::params::download_url,
  String[1] $mongo_uri                           = $mongodb::opsmanager::params::mongo_uri,
  Stdlib::Httpurl $opsmanager_url                = $mongodb::opsmanager::params::opsmanager_url,
  String[1] $client_certificate_mode             = 'None',
  String[1] $from_email_addr                     = 'from@example.com',
  String[1] $reply_to_email_addr                 = 'reply-to@example.com',
  String[1] $admin_email_addr                    = 'admin@example.com',
  String[1] $email_dao_class                     = 'com.xgen.svc.core.dao.email.JavaEmailDao', #AWS SES: com.xgen.svc.core.dao.email.AwsEmailDao or SMTP: com.xgen.svc.core.dao.email.JavaEmailDao
  Enum['smtp','smtps'] $mail_transport           = 'smtp',
  Stdlib::Host $smtp_server_hostname             = 'smtp.example.com', # if email_dao_class is SMTP: Email hostname your email provider specifies.
  Stdlib::Port $smtp_server_port                 = 25,
  Boolean $ssl                                   = false,
  Boolean $ignore_ui_setup                       = true,
  #optional settings
  Optional[String[1]] $ca_file                   = $mongodb::opsmanager::params::ca_file,
  Optional[String[1]] $pem_key_file              = $mongodb::opsmanager::params::pem_key_file,
  Optional[String[1]] $pem_key_password          = $mongodb::opsmanager::params::pem_key_password,
  Optional[String[1]] $user_svc_class            = undef, # Default: com.xgen.svc.mms.svc.user.UserSvcDb External Source: com.xgen.svc.mms.svc.user.UserSvcCrowd or Internal Database: com.xgen.svc.mms.svc.user.UserSvcDb
  Optional[Integer] $snapshot_interval           = undef, # Default: 24
  Optional[Integer] $snapshot_interval_retention = undef, # Default: 2
  Optional[Integer] $snapshot_daily_retention    = undef, # Default: 0
  Optional[Integer] $snapshot_weekly_retention   = undef, # Default: 2
  Optional[Integer] $snapshot_monthly_retention  = undef, # Default: 1
  Optional[Integer] $versions_directory          = undef, # Linux default: /opt/mongodb/mms/mongodb-releases/

  ) inherits mongodb::opsmanager::params {

  contain mongodb::opsmanager::install
  contain mongodb::opsmanager::config
  contain mongodb::opsmanager::service

  if ($mongo_uri == 'mongodb://127.0.0.1:27017') {
    include mongodb::server
  }

  if ($ensure == 'running') {
    Class['mongodb::opsmanager::install']
    ~> Class['mongodb::opsmanager::config']
    ~> Class['mongodb::opsmanager::service']
  }
}
