# inifile

[![Build Status](https://travis-ci.org/puppetlabs/puppetlabs-inifile.png?branch=master)](https://travis-ci.org/puppetlabs/puppetlabs-inifile)

#### Table of Contents

1. [Overview](#overview)
1. [Module Description - What the module does and why it is useful](#module-description)
1. [Setup - The basics of getting started with inifile module](#setup)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

<a id="overview"></a>
## Overview

The inifile module lets Puppet manage settings stored in INI-style configuration files.

<a id="module-description"></a>
## Module Description

Many applications use INI-style configuration files to store their settings. This module supplies two custom resource types to let you manage those settings through Puppet.

<a id="setup"></a>
## Setup

### Beginning with inifile

To manage a single setting in an INI file, add the `ini_setting` type to a class:

~~~puppet
ini_setting { "sample setting":
  ensure  => present,
  path    => '/tmp/foo.ini',
  section => 'bar',
  setting => 'baz',
  value   => 'quux',
}
~~~

<a id="usage"></a>
## Usage


The inifile module is used to:

 * Support comments starting with either '#' or ';'.
 * Support either whitespace or no whitespace around '='.
 * Add any missing sections to the INI file.

It does not manipulate your file any more than it needs to. In most cases, it doesn't affect the original whitespace, comments, or ordering. See the common usages below for examples.

### Manage multiple values in a setting

Use the `ini_subsetting` type:

~~~puppet
ini_subsetting {'sample subsetting':
  ensure            => present,
  section           => '',
  key_val_separator => '=',
  path              => '/etc/default/pe-puppetdb',
  setting           => 'JAVA_ARGS',
  subsetting        => '-Xmx',
  value             => '512m',
}
~~~

Results in managing this `-Xmx` subsetting:

~~~puppet
JAVA_ARGS="-Xmx512m -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/var/log/pe-puppetdb/puppetdb-oom.hprof"
~~~


### Use a non-standard section header

~~~puppet
ini_setting { 'default minage':
  ensure         => present,
  path           => '/etc/security/users',
  section        => 'default',
  setting        => 'minage',
  value          => '1',
  section_prefix => '',
  section_suffix => ':',
}
~~~

Results in:

~~~puppet
default:
   minage = 1
~~~

### Use a non-standard indent character

To use a non-standard indent character or string for added settings, set the `indent_char` and the `indent_width` parameters. The `indent_width` parameter controls how many `indent_char` appear in the indent.


~~~puppet
ini_setting { 'procedure cache size':
  ensure         => present,
  path           => '/var/lib/ase/config/ASE-16_0/SYBASE.cfg',
  section        => 'SQL Server Administration',
  setting        => 'procedure cache size',
  value          => '15000',
  indent_char    => "\t",
  indent_width   => 2,
}
~~~

Results in:

~~~puppet
[SQL Server Administration]
		procedure cache size = 15000
~~~

### Implement child providers

You might want to create child providers that inherit the `ini_setting` provider for one of the following reasons:

 * To make a custom resource to manage an application that stores its settings in INI files, without recreating the code to manage the files themselves.
 * To [purge all unmanaged settings](https://docs.puppetlabs.com/references/latest/type.html#resources-attribute-purge) from a managed INI file.

To implement child providers, first specify a custom type. Have it implement a namevar called `name` and a property called `value`:

~~~ruby
#my_module/lib/puppet/type/glance_api_config.rb
Puppet::Type.newtype(:glance_api_config) do
  ensurable
  newparam(:name, :namevar => true) do
    desc 'Section/setting name to manage from glance-api.conf'
    # namevar should be of the form section/setting
    newvalues(/\S+\/\S+/)
  end
  newproperty(:value) do
    desc 'The value of the setting to define'
    munge do |v|
      v.to_s.strip
    end
  end
end
~~~

Your type also needs a provider that uses the `ini_setting` provider as its parent:

~~~ruby
# my_module/lib/puppet/provider/glance_api_config/ini_setting.rb
Puppet::Type.type(:glance_api_config).provide(
  :ini_setting,
  # set ini_setting as the parent provider
  :parent => Puppet::Type.type(:ini_setting).provider(:ruby)
) do
  # implement section as the first part of the namevar
  def section
    resource[:name].split('/', 2).first
  end
  def setting
    # implement setting as the second part of the namevar
    resource[:name].split('/', 2).last
  end
  # hard code the file path (this allows purging)
  def self.file_path
    '/etc/glance/glance-api.conf'
  end
end
~~~

Now you can manage the settings in the `/etc/glance/glance-api.conf` file as individual resources:

~~~puppet
glance_api_config { 'HEADER/important_config':
  value => 'secret_value',
}
~~~

If you've implemented `self.file_path`, you can have Puppet purge the file of the all lines that aren't implemented as Puppet resources:

~~~puppet
resources { 'glance_api_config'
  purge => true,
}
~~~

### Manage multiple ini_settings

To manage multiple `ini_settings`, use the [`create_ini_settings`](#function-create_ini_settings) function.

~~~puppet
$defaults = { 'path' => '/tmp/foo.ini' }
$example = { 'section1' => { 'setting1' => 'value1' } }
create_ini_settings($example, $defaults)
~~~

Results in:

~~~puppet
ini_setting { '[section1] setting1':
  ensure  => present,
  section => 'section1',
  setting => 'setting1',
  value   => 'value1',
  path    => '/tmp/foo.ini',
}
~~~

To include special parameters, use the following code:

~~~puppet
$defaults = { 'path' => '/tmp/foo.ini' }
$example = {
  'section1' => {
    'setting1'  => 'value1',
    'settings2' => {
      'ensure' => 'absent'
    }
  }
}
create_ini_settings($example, $defaults)
~~~

Results in:

~~~puppet
ini_setting { '[section1] setting1':
  ensure  => present,
  section => 'section1',
  setting => 'setting1',
  value   => 'value1',
  path    => '/tmp/foo.ini',
}
ini_setting { '[section1] setting2':
  ensure  => absent,
  section => 'section1',
  setting => 'setting2',
  path    => '/tmp/foo.ini',
}
~~~

#### Manage multiple ini_settings with Hiera

This example requires Puppet 3.x/4.x, as it uses automatic retrieval of Hiera data for class parameters and `puppetlabs/stdlib`.

For the profile `example`:

~~~puppet
class profile::example (
  $settings,
) {
  validate_hash($settings)
  $defaults = { 'path' => '/tmp/foo.ini' }
  create_ini_settings($settings, $defaults)
}
~~~

Provide this in your Hiera data:

~~~puppet
profile::example::settings:
  section1:
    setting1: value1
    setting2: value2
    setting3:
      ensure: absent
~~~

Results in:

~~~puppet
ini_setting { '[section1] setting1':
  ensure  => present,
  section => 'section1',
  setting => 'setting1',
  value   => 'value1',
  path    => '/tmp/foo.ini',
}
ini_setting { '[section1] setting2':
  ensure  => present,
  section => 'section1',
  setting => 'setting2',
  value   => 'value2',
  path    => '/tmp/foo.ini',
}
ini_setting { '[section1] setting3':
  ensure  => absent,
  section => 'section1',
  setting => 'setting3',
  path    => '/tmp/foo.ini',
}
~~~

<a id="reference"></a> 
## Reference
See [REFERENCE.md](https://github.com/puppetlabs/puppetlabs-inifile/blob/master/REFERENCE.md)

<a id="limitations"></a>
## Limitations

Due to (PUP-4709) the create_ini_settings function will cause errors when attempting to create multiple ini_settings in one go when using Puppet 4.0.x or 4.1.x. If needed, the temporary fix for this can be found here: https://github.com/puppetlabs/puppetlabs-inifile/pull/196.

For an extensive list of supported operating systems, see [metadata.json](https://github.com/puppetlabs/puppetlabs-inifile/blob/master/metadata.json)

<a id="development"></a> 
## Development

We are experimenting with a new tool for running acceptance tests. It's name is [puppet_litmus](https://github.com/puppetlabs/puppet_litmus) this replaces beaker as the test runner. To run the acceptance tests follow the instructions [here](https://github.com/puppetlabs/puppet_litmus/wiki/Tutorial:-use-Litmus-to-execute-acceptance-tests-with-a-sample-module-(MoTD)#install-the-necessary-gems-for-the-module).

Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can't access the huge number of platforms and myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

For more information, see our [module contribution guide.](https://puppet.com/docs/puppet/latest/contributing.html)

### Contributors

To see who's already involved, see the [list of contributors.](https://github.com/puppetlabs/puppetlabs-inifile/graphs/contributors)
