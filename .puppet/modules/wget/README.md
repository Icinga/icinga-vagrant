# rehan-wget

[![Puppet Forge](http://img.shields.io/puppetforge/v/rehan/wget.svg)](https://forge.puppetlabs.com/rehan/wget) [![Build Status](https://travis-ci.org/rehanone/puppet-wget.svg?branch=master)](https://travis-ci.org/rehanone/puppet-wget)

#### Table of Contents
1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
4. [Usage](#usage)
    * [Classes](#classes)
    * [Referances](#referances)
5. [Dependencies](#dependencies)
6. [Development](#development)

## Overview
The `rehan-wget` module that can install wget and retrieve files using it.

## Module Description
This module is a clone of [maestrodev-wget](https://forge.puppet.com/maestrodev/wget) without any legacy support for 
puppet versions older than 4.0. It manages installation of wget and supports retrieval of files and directories from the 
Internet.

#### Implemented Features:
* Installs and manages wget package
* Retrieve files and directories using wget.

## Setup
In order to install `rehan-wget`, run the following command:
```bash
$ puppet module install rehan-wget
```
The module can be used with `hiera` to provide all configuration options. See [Usage](#usage) for examples on how to configure it.

#### Requirements
This module is designed to be as clean and compliant with latest puppet code guidelines. It works with:

  - `puppet >=5.5.10`

## Usage

### Classes

#### `wget`

A basic install with the defaults would be:
```puppet
include wget
```

Otherwise using the parameters:  
```puppet
  class{ 'wget':
    package_manage  => true,
    package_ensure  => present,
    package_name    => 'wget',
  }
```

##### Parameters

* **package_manage**: Controls the wget package management by this module. The default is `true`. If it is `false`, this module will not manage wget.
* **package_ensure**: Sets the ensure parameter passed to the package. The default is `present`.
* **package_name**: Provides the package name to be installed. The default is `wget`. It can be used on systems where the default name is other than that.
* **retrievals**: A hash of retrieve resources that this module can download, see `wget::retrieve` for more details.


All of this data can be provided through `Hiera`. 

**YAML**
```yaml
wget::package_manage: true
wget::package_ensure: present
wget::package_name: 'wget'
wget::retrievals:
  'http://www.google.com/index.html':
    destination: '/tmp/'
    timeout: 0
```

### Resources

#### `wget::retrieve`


Usage:


```puppet
    wget::retrieve { "download Google's index":
      source      => 'http://www.google.com/index.html',
      destination => '/tmp/',
      timeout     => 0,
      verbose     => false,
    }
```
or alternatively: 

```puppet
    wget::retrieve { 'http://www.google.com/index.html':
      destination => '/tmp/',
      timeout     => 0,
      verbose     => false,
    }
```

If `$destination` ends in either a forward or backward slash, it will treat the destination as a directory and name the file with the basename of the `$source`.
```puppet
  wget::retrieve { 'http://mywebsite.com/apples':
    destination => '/downloads/',
  }
```

Download from an array of URLs into one directory
```puppet
  $manyfiles = [
    'http://mywebsite.com/apples',
    'http://mywebsite.com/oranges',
    'http://mywebsite.com/bananas',
  ]

  wget::retrieve { $manyfiles:
    destination => '/downloads/',
  }
```

This retrieves a document which requires authentication:

```puppet
    wget::retrieve { 'Retrieve secret PDF':
      source      => 'https://confidential.example.com/secret.pdf',
      destination => '/tmp/',
      user        => 'user',
      password    => 'p$ssw0rd',
      timeout     => 0,
      verbose     => false,
    }
```

This caches the downloaded file in an intermediate directory to avoid
repeatedly downloading it. This uses the timestamping (-N) and prefix (-P)
wget options to only re-download if the source file has been updated.

```puppet
    wget::retrieve { 'https://tool.com/downloads/tool-1.0.tgz':
      destination => '/tmp/',
      cache_dir   => '/var/cache/wget',
    }
```

It's assumed that the cached file will be named after the source's URL
basename but this assumption can be broken if wget follows some redirects. In
this case you must inform the correct filename in the cache like this:

```puppet
    wget::retrieve { 'https://tool.com/downloads/tool-latest.tgz':
      destination => '/tmp/tool-1.0.tgz',
      cache_dir   => '/var/cache/wget',
      cache_file  => 'tool-1.1.tgz',
      execuser    => 'fileowner',
      group       => 'filegroup',
    }
```

Checksum can be used in the `source_hash` parameter, with the MD5-sum of the content to be downloaded.
If content exists, but does not match it is removed before downloading.

If you want to use your own unless condition, you can do it. This example uses wget to download the latest version of Wordpress to your destination folder only if the folder is empty (test used returns 1 if directory is empty or 0 if not).
```puppet
    wget::retrieve { 'wordpress':
        source      => 'https://wordpress.org/latest.tar.gz',
        destination => "/var/www/html/latest_wordpress.tar.gz",
        timeout     => 0,
        unless      => "test $(ls -A /var/www/html 2>/dev/null)",
    }
```

## Dependencies

* [stdlib][1]

[1]:https://forge.puppet.com/puppetlabs/stdlib

## Development

You can submit pull requests and create issues through the official page of this module on [GitHub](https://github.com/rehanone/puppet-wget).
Please do report any bug and suggest new features/improvements.
