require 'digest/md5'

Puppet::Type.newtype(:ini_subsetting) do
  desc 'ini_subsettings is used to manage multiple values in a setting in an INI file'
  ensurable do
    desc 'Ensurable method handles modeling creation. It creates an ensure property'
    defaultvalues
    defaultto :present
  end

  def munge_boolean_md5(value)
    case value
    when true, :true, 'true', :yes, 'yes'
      :true
    when false, :false, 'false', :no, 'no'
      :false
    when :md5, 'md5'
      :md5
    else
      raise(_('expected a boolean value or :md5'))
    end
  end
  newparam(:name, namevar: true) do
    desc 'An arbitrary name used as the identity of the resource.'
  end

  newparam(:section) do
    desc 'The name of the section in the ini file in which the setting should be defined.'
    defaultto('')
  end

  newparam(:setting) do
    desc 'The name of the setting to be defined.'
  end

  newparam(:subsetting) do
    desc 'The name of the subsetting to be defined.'
  end

  newparam(:subsetting_separator) do
    desc 'The separator string between subsettings. Defaults to the empty string.'
    defaultto(' ')
  end

  newparam(:subsetting_key_val_separator) do
    desc 'The separator string between the subsetting name and its value. Defaults to the empty string.'
    defaultto('')
  end

  newparam(:path) do
    desc 'The ini file Puppet will ensure contains the specified setting.'
    validate do |value|
      unless Puppet::Util.absolute_path?(value)
        raise(Puppet::Error, _("File paths must be fully qualified, not '%{value}'") % { value: value })
      end
    end
  end
  newparam(:show_diff) do
    desc 'Whether to display differences when the setting changes.'
    defaultto :true
    newvalues(:true, :md5, :false)

    munge do |value|
      @resource.munge_boolean_md5(value)
    end
  end

  newparam(:key_val_separator) do
    desc 'The separator string to use between each setting name and value.'
    defaultto(' = ')
  end

  newparam(:quote_char) do
    desc "The character used to quote the entire value of the setting. Valid values are '', '\"' and \"'\""
    defaultto('')

    validate do |value|
      unless value =~ %r{^["']?$}
        raise Puppet::Error, _(%q(:quote_char valid values are '', '"' and "'"))
      end
    end
  end

  newparam(:use_exact_match) do
    desc 'Set to true if your subsettings don\'t have values and you want to use exact matches to determine if the subsetting exists.'
    newvalues(:true, :false)
    defaultto(:false)
  end

  newproperty(:value) do
    desc 'The value of the subsetting to be defined.'

    def should_to_s(newvalue)
      if @resource[:show_diff] == :true && Puppet[:show_diff]
        newvalue
      elsif @resource[:show_diff] == :md5 && Puppet[:show_diff]
        '{md5}' + Digest::MD5.hexdigest(newvalue.to_s)
      else
        '[redacted sensitive information]'
      end
    end

    def is_to_s(value) # rubocop:disable Style/PredicateName : Changing breaks the code (./.bundle/gems/gems/puppet-5.3.3-universal-darwin/lib/puppet/parameter.rb:525:in `to_s')
      should_to_s(value)
    end
  end

  newparam(:insert_type) do
    desc <<-eof
      Where the new subsetting item should be inserted

      * :start  - insert at the beginning of the line.
      * :end    - insert at the end of the line (default).
      * :before - insert before the specified element if possible.
      * :after  - insert after the specified element if possible.
      * :index  - insert at the specified index number.
    eof

    newvalues(:start, :end, :before, :after, :index)
    defaultto(:end)
  end

  newparam(:insert_value) do
    desc 'The value for the insert types which require one.'
  end
end
