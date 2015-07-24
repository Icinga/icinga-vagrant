#java

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with the java module](#setup)
    * [Beginning with the java module](#beginning-with-the-java-module)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)

##Overview

Installs the correct Java package on various platforms. 

##Module Description

The java module can automatically install Java jdk or jre on a wide variety of systems. Java is a base component for many software platforms, but Java system packages don't always follow packaging conventions. The java module simplifies the Java installation process.

##Setup

###Beginning with the java module
To install the correct Java package on your system, include the `java` class: `include java`.

##Usage

The java module installs the correct jdk or jre package on a wide variety of systems. By default, the module will install the jdk package, but you can set different installation parameters as needed. For example, to install jre instead of jdk, you would set the distribution parameter:

~~~
class { 'java':
  distribution => 'jre',
}
~~~

##Reference

###Classes

####Public classes

* `java`: Installs and manages the Java package.

####Private classes

* `java::config`: Configures the Java alternatives.

* `java::params`: Builds a hash of jdk/jre packages for all compatible operating systems.

####Parameters
The following parameters are available in `java`:

##### `distribution`
Specifies the Java distribution to install.  
Valid options:  'jdk', 'jre', or, where the platform supports alternative packages, 'sun-jdk', 'sun-jre', 'oracle-jdk', 'oracle-jre'. Default: 'jdk'.

#####`java_alternative`
Specifies the name of the Java alternative to use. If you set this parameter, *you must also set the `java_alternative_path`.*  
Valid options: Run command `update-java-alternatives -l` for a list of available choices. Default: OS and distribution dependent defaults on *deb systems, undef on others.

#####`java_alternative_path`  
*Required when `java_alternative` is specified.* Defines the path to the `java` command.  
Valid option: String. Default: OS and distribution dependent defaults on *deb systems, undef on others.

#####`package`
Specifies the name of the Java package. This is configurable in case you want to install a non-standard Java package. If not set, the module will install the appropriate package for the `distribution` parameter and target platform. If you set `package`, the `distribution` parameter will do nothing.  
Valid option: String. Default: undef. 

#####`version`
Sets the version of Java to install, if you want to ensure a particular version.  
Valid options: 'present', 'installed', 'latest', or a string matching `/^[.+_0-9a-zA-Z:-]+$/`. Default: 'present'.


###Facts

The java module includes a few facts to describe the version of Java installed on the system:

* `java_major_version`: The major version of Java.
* `java_patch_level`: The patch level of Java.
* `java_version`: The full Java version string.

**Note:** The facts return `nil` if Java is not installed on the system.

##Limitations

This module cannot guarantee installation of Java versions that are not available on  platform repositories. 

This module only manages a singular installation of Java, meaning it is not possible to manage e.g. OpenJDK 7, Oracle Java 7 and Oracle Java 8 in parallel on the same system.

Oracle Java packages are not included in Debian 7 and Ubuntu 12.04/14.04 repositories. To install Java on those systems, you'll need to package Oracle JDK/JRE, and then the module will be able to install the package. For more information on how to package Oracle JDK/JRE, see the [Debian wiki](http://wiki.debian.org/JavaPackage).

This module is officially [supported](https://forge.puppetlabs.com/supported) for the following Java versions and platforms:

OpenJDK is supported on:  

* Red Hat Enterprise Linux (RHEL) 5, 6, 7
* CentOS 5, 6, 7
* Oracle Linux 6, 7
* Scientific Linux 5, 6
* Debian 6, 7
* Ubuntu 10.04, 12.04, 14.04
* Solaris 11
* SLES 11 SP1, 12 
* OpenBSD 5.6, 5.7

Sun Java is supported on:  

* Debian 6

### A note to OpenBSD
OpenBSD packages install Java JRE/JDK in a unique directory structure, not linking
the binaries to a standard directory. Because of that, the path to this location
is hardcoded in the java_version fact. Whenever a Java upgrade to a newer
version/path will be done on OpenBSD, it has to be adapted there.

##Development

Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can’t access the huge number of platforms and myriad hardware, software, and deployment configurations that Puppet is intended to serve. We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things. For more information, see our [module contribution guide.](https://docs.puppetlabs.com/forge/contributing.html)

##Contributors

The list of contributors can be found at: [https://github.com/puppetlabs/puppetlabs-java/graphs/contributors](https://github.com/puppetlabs/puppetlabs-java/graphs/contributors).
