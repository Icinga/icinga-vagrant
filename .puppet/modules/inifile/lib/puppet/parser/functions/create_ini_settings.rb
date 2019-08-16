#
# create_ini_settings.rb
#
module Puppet::Parser::Functions
  newfunction(:create_ini_settings, type: :statement, doc: <<-EOS
    @return [String] Returns a string.
    create_resources is used to create a set of ini_setting resources from a hash
    EOS
             ) do |arguments|

    unless arguments.size.between?(1, 2)
      raise(Puppet::ParseError, _('create_ini_settings(): Wrong number of arguments ' \
        'given (%{arguments_size} for 1 or 2)') % { arguments_size: arguments.size })
    end

    settings = arguments[0]
    defaults = arguments[1] || {}

    if [settings, defaults].any? { |i| !i.is_a?(Hash) }
      raise(Puppet::ParseError,
            _('create_ini_settings(): Requires all arguments to be a Hash'))
    end

    resources = settings.keys.each_with_object({}) do |section, res|
      unless settings[section].is_a?(Hash)
        raise(Puppet::ParseError,
              _('create_ini_settings(): Section %{section} must contain a Hash') % { section: section })
      end

      path = defaults.merge(settings)['path']
      raise Puppet::ParseError, _('create_ini_settings(): must pass the path parameter to the Ini_setting resource!') unless path

      settings[section].each do |setting, value|
        res["#{path} [#{section}] #{setting}"] = {
          'ensure'  => 'present',
          'section' => section,
          'setting' => setting,
        }.merge(if value.is_a?(Hash)
                  value
                else
                  { 'value' => value }
                end)
      end
    end

    Puppet::Parser::Functions.function('create_resources')
    function_create_resources(['ini_setting', resources, defaults])
  end
end

# vim: set ts=2 sw=2 et :
