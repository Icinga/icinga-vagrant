require File.expand_path('../../../util/ini_file', __FILE__)

Puppet::Type.type(:ini_setting).provide(:ruby) do
  def self.instances
    desc '
    Creates new ini_setting file, a specific config file with a provider that uses
    this as its parent and implements the method
    self.file_path, and that will provide the value for the path to the
    ini file.'
    raise(Puppet::Error, 'Ini_settings only support collecting instances when a file path is hard coded') unless respond_to?(:file_path)
    # figure out what to do about the seperator
    ini_file  = Puppet::Util::IniFile.new(file_path, '=')
    resources = []
    ini_file.section_names.each do |section_name|
      ini_file.get_settings(section_name).each do |setting, value|
        resources.push(
          new(
            name: namevar(section_name, setting),
            value: value,
            ensure: :present,
          ),
        )
      end
    end
    resources
  end

  def self.namevar(section_name, setting)
    setting.nil? ? section_name : "#{section_name}/#{setting}"
  end

  def exists?
    setting.nil? && ini_file.section_names.include?(section) || !ini_file.get_value(section, setting).nil?
    if ini_file.section?(section)
      !ini_file.get_value(section, setting).nil?
    elsif resource.parameters.keys.include?(:force_new_section_creation) && !resource[:force_new_section_creation]
      # for backwards compatibility, if a user is using their own ini_setting
      # types but does not have this parameter, we need to fall back to the
      # previous functionality which was to create the section.  Anyone
      # wishing to leverage this setting must define it in their provider
      # type. See comments on
      # https://github.com/puppetlabs/puppetlabs-inifile/pull/286
      resource[:ensure] = :absent
      resource[:force_new_section_creation]
    elsif resource.parameters.keys.include?(:force_new_section_creation) && resource[:force_new_section_creation]
      !resource[:force_new_section_creation]
    else
      false
    end
  end

  def create
    if setting.nil? && resource[:value].nil?
      ini_file.set_value(section)
    else
      ini_file.set_value(section, setting, separator, resource[:value])
    end
    ini_file.save
    @ini_file = nil
  end

  def destroy
    ini_file.remove_setting(section, setting)
    ini_file.save
    @ini_file = nil
  end

  def value
    ini_file.get_value(section, setting)
  end

  def value=(_value)
    if setting.nil? && resource[:value].nil?
      ini_file.set_value(section)
    else
      ini_file.set_value(section, setting, separator, resource[:value])
    end
    ini_file.save
  end

  def section
    # this method is here so that it can be overridden by a child provider
    resource[:section]
  end

  def setting
    # this method is here so that it can be overridden by a child provider
    resource[:setting]
  end

  def file_path
    # this method is here to support purging and sub-classing.
    # if a user creates a type and subclasses our provider and provides a
    # 'file_path' method, then they don't have to specify the
    # path as a parameter for every ini_setting declaration.
    # This implementation allows us to support that while still
    # falling back to the parameter value when necessary.
    if self.class.respond_to?(:file_path)
      self.class.file_path
    else
      resource[:path]
    end
  end

  def separator
    if resource.class.validattr?(:key_val_separator)
      resource[:key_val_separator] || '='
    else
      '='
    end
  end

  def section_prefix
    if resource.class.validattr?(:section_prefix)
      resource[:section_prefix] || '['
    else
      '['
    end
  end

  def section_suffix
    if resource.class.validattr?(:section_suffix)
      resource[:section_suffix] || ']'
    else
      ']'
    end
  end

  def indent_char
    if resource.class.validattr?(:indent_char)
      resource[:indent_char] || ' '
    else
      ' '
    end
  end

  def indent_width
    if resource.class.validattr?(:indent_width)
      resource[:indent_width] || nil
    else
      nil
    end
  end

  private

  def ini_file
    @ini_file ||= Puppet::Util::IniFile.new(file_path, separator, section_prefix, section_suffix, indent_char, indent_width)
  end
end
