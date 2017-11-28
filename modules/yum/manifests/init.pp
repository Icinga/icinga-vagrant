# A class to install and manage Yum configuration.
#
# @param clean_old_kernels [Boolean]
#   Whether or not to purge old kernel version beyond the `keeponly_limit`.
#
# @param keep_kernel_devel [Boolean]
#   Whether or not to keep kernel devel packages on old kernel purge.
#
# @param config_options [Hash]
#   A Hash where keys are the names of `Yum::Config` resources and the values
#   are either the direct `ensure` value, or a Hash of the resource's attributes.
#
#   @note Boolean parameter values will be converted to either a `1` or `0`; use a quoted string to
#     get a literal `true` or `false`.
#
# @param repos [Hash]
#   A hash where keys are the names of `Yumrepo` resources and each value represents its respective
#   Yumrepo's resource parameters.  This is used in conjunction with the `managed_repos` parameter
#   to create `Yumrepo` resources en masse.  Some default data is provided for this using module
#   data.  It is configured to deep merge with a `knockout_prefix` of `--` by default, so individual
#   parameters may be overriden or removed via global or environment Hiera data.
#
#   @note Boolean parameter values will be converted to either a `1` or `0`; use a quoted string to
#     get a literal `true` or `false`.
#
# @param managed_repos [Array]
#   An array of first-level keys from the `repos` hash to include in the catalog.  The module uses
#   this list to select `Yumrepo` resources from the `repos` hash for instantiation.  Defaults are
#   set in the module's Hiera data.
#
#   @note This only indicates the *managed* state of the repos, the `ensure` state must be managed
#     in the `repos` data.
#
# @param manage_os_default_repos [Boolean]
#   Whether or not to add an operating system's default repos to the `managed_repos` array.
#
#   @note This only works for operating systems with data in the module's data directory.  Currently
#     the module only contains data for for CentOS 6 & 7.
#
# @param os_default_repos [Array]
#   A list of default repos to add to `managed_repos` if `manage_os_default_repos` is enabled.
#   Normally this should not be modified.
#
# @param repo_exclusions [Array]
#   An array of first-level keys from the `repos` hash to exclude from management via this module.
#   Values in this array will be subtracted from the `managed_repos` array as a last step before
#   instantiation.
#
# @example Enable management of the default repos for a supported OS:
#   ```yaml
#   ---
#   yum::manage_os_default_repos: true
#   ```
#
# @example Add Hiera data to disable *management* of the CentOS Base repo:
#   ```yaml
#   ---
#   yum::manage_os_default_repos: true
#   yum::repo_exclusions:
#       - 'base'
#   ```
#
# @example Ensure the CentOS base repo is removed from the agent system(s):
#   ```yaml
#   ---
#   yum::manage_os_default_repos: true
#   yum::repos:
#       base:
#           ensure: 'absent'
#   ```
#
# @example Add a custom repo:
#   ```yaml
#   ---
#   yum::managed_repos:
#       - 'example_repo'
#   yum::repos:
#       example_repo:
#           ensure: 'present'
#           enabled: true
#           descr: 'Example Repo'
#           baseurl: 'https://repos.example.com/example/'
#           gpgcheck: true
#           gpgkey: 'file:///etc/pki/gpm-gpg/RPM-GPG-KEY-Example'
#           target: '/etc/yum.repos.d/example.repo'
#   ```
#
# @example Use a custom `baseurl` for the CentOS Base repo:
#   ```yaml
#   ---
#   yum::manage_os_default_repos: true
#   yum::repos:
#       base:
#           baseurl: 'https://repos.example.com/CentOS/base/'
#           mirrorlist: '--'
#   ```
#
class yum (
  Boolean $clean_old_kernels = true,
  Boolean $keep_kernel_devel = false,
  Hash[String, Variant[String, Integer, Boolean, Hash[String, Variant[String, Integer, Boolean]]]] $config_options = { },
  Optional[Hash[String, Optional[Hash[String, Variant[String, Integer, Boolean]]]]] $repos = {},
  Array[String] $managed_repos = [],
  Boolean $manage_os_default_repos = false,
  Array[String] $os_default_repos = [],
  Array[String] $repo_exclusions = [],
) {

  $module_metadata            = load_module_metadata($module_name)
  $supported_operatingsystems = $module_metadata['operatingsystem_support']
  $supported_os_names         = $supported_operatingsystems.map |$os| {
    $os['operatingsystem']
  }

  unless member($supported_os_names, $::os['name']) {
    fail("${::os['name']} not supported")
  }

  $_managed_repos = $manage_os_default_repos ? {
    true    => $managed_repos + $os_default_repos,
    default => $managed_repos,
  }

  unless empty($_managed_repos) or empty($repos) {
    $_managed_repos_minus_exclusions = $_managed_repos - $repo_exclusions
    $normalized_repos = yum::bool2num_hash_recursive($repos)

    $normalized_repos.each |$yumrepo, $attributes| {
      if member($_managed_repos_minus_exclusions, $yumrepo) {
        Resource['yumrepo'] {
          $yumrepo: * => $attributes,
        }
      }
    }
  }

  unless empty($config_options) {
    if has_key($config_options, 'installonly_limit') {
      assert_type(Variant[Integer, Hash[String, Integer]], $config_options['installonly_limit']) |$expected, $actual| {
        fail("The value or ensure for `\$yum::config_options[installonly_limit]` must be an Integer, but it is not.")
      }
    }

    $_normalized_config_options = $config_options.map |$key, $attrs| {
      $_ensure = $attrs ? {
        Hash    => $attrs[ensure],
        default => $attrs,
      }

      $_normalized_ensure = $_ensure ? {
        Boolean => Hash({ ensure => bool2num($_ensure) }), # lint:ignore:unquoted_string_in_selector
        default => Hash({ ensure => $_ensure }), # lint:ignore:unquoted_string_in_selector
      }

      $_normalized_attrs = $attrs ? {
        Hash    => merge($attrs, $_normalized_ensure),
        default => $_normalized_ensure,
      }

      Hash({ $key => $_normalized_attrs })
    }.reduce |$memo, $cfg_opt_hash| {
      merge($memo, $cfg_opt_hash)
    }

    $_normalized_config_options.each |$config, $attributes| {
      Resource['yum::config'] {
        $config: * => $attributes,
      }
    }
  }

  unless defined(Yum::Config['installonly_limit']) {
    yum::config { 'installonly_limit': ensure => '3' }
  }

  $_clean_old_kernels_subscribe = $clean_old_kernels ? {
    true    => Yum::Config['installonly_limit'],
    default => undef,
  }

  # cleanup old kernels
  ensure_packages(['yum-utils'])

  $_real_installonly_limit = $config_options['installonly_limit'] ? {
    Variant[String, Integer] => $config_options['installonly_limit'],
    Hash                     => $config_options['installonly_limit']['ensure'],
    default                  => '3',
  }

  $_pc_cmd = delete_undef_values([
    '/usr/bin/package-cleanup',
    '--oldkernels',
    "--count=${_real_installonly_limit}",
    '-y',
    $keep_kernel_devel ? {
      true    => '--keepdevel',
      default => undef,
    },
  ])

  exec { 'package-cleanup_oldkernels':
    command     => shellquote($_pc_cmd),
    refreshonly => true,
    require     => Package['yum-utils'],
    subscribe   => $_clean_old_kernels_subscribe,
  }
}
