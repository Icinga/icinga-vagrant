# puppet-lib-file_concat

#### Table of Contents

1. [Overview](#overview)
2. [Usage - Configuration options and additional functionality](#usage)
3. [Limitations - OS compatibility, etc.](#limitations)
4. [Development - Guide for contributing to the module](#development)

## Overview

Library for concatenating multiple files into 1.

## Usage

### Creating a file fragment

Creates a file fragment to be collected by file_concat based on the tag.

Example with exported resource:

    @@file_fragment { "uniqe_name_${::fqdn}":
      tag     => 'unique_tag',            # Mandatory.
      order   => 10,                      # Optional. Defaults to 10.
      content => 'some content'           # OR
      content => template('template.erb') # OR
      source  => 'puppet:///path/to/file'
    }

### Concatenating file fragments into one file

Gets all the file fragments and puts these into the target file.
This will mostly be used with exported resources.

example:
    
    File_fragment <<| tag == 'unique_tag' |>>

    file_concat { '/tmp/file':
      tag            => 'unique_tag', # Mandatory
      path           => '/tmp/file',  # Optional. If given it overrides the resource name.
      owner          => 'root',       # Optional. Defaults to undef.
      group          => 'root',       # Optional. Defaults to undef.
      mode           => '0644',       # Optional. Defaults to undef.
      order          => 'numeric',    # Optional. Set to 'numeric' or 'alpha'. Defaults to numeric.
      replace        => true,         # Optional. Boolean Value. Defaults to true.
      backup         => false,        # Optional. true, false, 'puppet', or a string. Defaults to 'puppet' for Filebucketing.
      ensure_newline => false,        # Optional. Boolean Value. Defaults to false.
    }

## Limitations

A bug where module will be unable to build correct dependency graph if the manifest contains a resource to recursively purge a parent directory.

Example: [MODULES-2054](https://tickets.puppetlabs.com/browse/MODULES-2054)
~~~
file { '/tmp/bug':
  ensure  => directory,
  purge   => true,
  recurse => true,
  force   => true
}
 
file_concat { 'test' :
  path    => '/tmp/bug/tester',
  tag     => 'mytag',
  require => File['/tmp/bug']
}
 
file_fragment { 'test-1':
  tag     => 'mytag',
  content => 'test'
}
~~~

## Development

