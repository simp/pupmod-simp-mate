[![License](https://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/73/badge)](https://bestpractices.coreinfrastructure.org/projects/73)
[![Puppet Forge](https://img.shields.io/puppetforge/v/simp/mate.svg)](https://forge.puppetlabs.com/simp/mate)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/simp/mate.svg)](https://forge.puppetlabs.com/simp/mate)
[![Build Status](https://travis-ci.org/simp/pupmod-simp-mate.svg)](https://travis-ci.org/simp/pupmod-simp-mate)

#### Table of Contents

* [Description](#description)
  * [This is a SIMP module](#this-is-a-simp-module)
* [Setup](#setup)
* [Usage](#usage)
* [Reference](#reference)
* [Limitations](#limitations)
* [Development](#development)

## Description

`mate` is a Puppet module that installs and manages MATE.

### This is a SIMP module

This module is a component of the [System Integrity Management Platform](https://simp-project.com)
a compliance-management framework built on Puppet.

If you find any issues, they may be submitted to our [bug tracker](https://simp-project.atlassian.net/).

This module is optimally designed for use within a larger SIMP ecosystem, but
it can be used independently:

 * When included within the SIMP ecosystem, security compliance settings will
   be managed from the Puppet server.
 * If used independently, all SIMP-managed security subsystems are disabled by
   default and must be explicitly opted into by administrators.  See
   [simp_options](https://github.com/simp/pupmod-simp-simp_options) for more
   detail.

## Setup

To use the module with default settings, just include the class:

```ruby
include 'mate'
```

## Usage

You can disable configuration of mate by setting `mate::configure` to false.
The module will then only install MATE.

This module makes heavy use of data. The `dconf` settings are all data-driven,
and the defaults can be seen in the
[common.yaml](data/common.yaml).

You can use the knockout prefix of `--` in front of a key to remove it from the
Hash, like this:

```yaml
mate::dconf_hash:
  simp_mate:
    --org/mate/settings-daemon/plugins/media-keys:
    org/mate/desktop/media-handling:
      --automount-open:
```

Or you can simply set it to the desired value.

`Dconf` settings are locked by default so that users can't change them.

This can be disabled on a per setting basis, like in this entry for wallpaper
in `mate::dconf_hash`:

```yaml
mate::dconf_hash:
  simp_mate:
    org/mate/desktop/background:
      picture-uri:
        value: file:///usr/local/corp/puppies.jpg
        lock: false
```

## Reference

See the [API documentation](http://www.puppetmodule.info/github/simp/pupmod-simp-mate/master)
or run `puppet strings` for full details.

## Limitations

SIMP Puppet modules are generally intended for use on Red Hat Enterprise Linux
and compatible distributions, such as CentOS.

Please see the [`metadata.json` file](./metadata.json) for the most up-to-date
list of supported operating systems, Puppet versions, and module dependencies.

This module is compatible with GDM v2, v3.

## Development

Please read our [Contribution Guide] (http://simp-doc.readthedocs.io/en/stable/contributors_guide/index.html)
