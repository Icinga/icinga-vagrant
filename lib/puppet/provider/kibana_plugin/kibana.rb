require 'puppet/provider/elastic_kibana'

Puppet::Type.type(:kibana_plugin).provide(
  :kibana,
  :parent => Puppet::Provider::ElasticKibana,
  :home_path => File.absolute_path(File.join(%w(/ opt kibana))),
  :install_args => ['plugin', '--install'],
  :plugin_directory => 'installedPlugins',
  :remove_args => ['plugin', '--remove']
) do
  desc 'Native command-line provider for Kibana v4 plugins.'

  commands :plugin => File.join(home_path, 'bin', 'kibana')
end
