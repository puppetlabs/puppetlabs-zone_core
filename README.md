# zone

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with zone](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with zone](#beginning-with-zone)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

The zone_core module is used to manage Solaris zone resources.

## Setup

### Setup Requirements

The zone_core module depends on the zfs_core module, as a zone may be associated in a zfs resource pool.

### Beginning with zone

To create a zone resource with the name `tstzone` in the `running` state and the root of the zone filesystem in `/tstzones/mnt`:
```
zone { 'tstzone' :
  ensure => running,
  path   => '/tstzones/mnt'
}

```

## Usage

For details on usage, please see [the zone puppet docs](https://puppet.com/docs/puppet/latest/types/zone.html).

## Reference

Please see REFERENCE.md for the reference documentation.

This module is documented using Puppet Strings.

For a quick primer on how Strings works, please see [this blog post](https://puppet.com/blog/using-puppet-strings-generate-great-documentation-puppet-modules) or the [README.md](https://github.com/puppetlabs/puppet-strings/blob/master/README.md) for Puppet Strings.

To generate documentation locally, run
```
bundle install
bundle exec puppet strings generate ./lib/**/*.rb
```
This command will create a browsable `\_index.html` file in the `doc` directory. The references available here are all generated from YARD-style comments embedded in the code base. When any development happens on this module, the impacted documentation should also be updated.

## Limitations

This module is only available on Solaris platforms.

## Development

Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can't access the huge number of platforms and myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

For more information, see our [module contribution guide.](https://docs.puppetlabs.com/forge/contributing.html)
