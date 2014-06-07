clamav Omnibus project
======================

This project creates full-stack platform-specific packages for `ClamAV`!

While most distros have their own vendor ClamAV packages, there are enough
differences between them to make maintaining the
[ClamAV Chef cookbook](http://community.opscode.com/cookbooks/clamav) much more
of a pain than it needs to be. For example,

* Some packages include service/init scripts; some don't
* Some packages use `/etc/`; some use `/etc/clamav/`

Usage
-----

This project uses Chef's [Omnibus](https://github.com/opscode/omnibus-ruby)
project, driven by [Vagrant](http://www.vagrantup.com) and
[VirtualBox](https://www.virtualbox.org) to spawn build machines for each
supported distro.

To get started, you must have Ruby 1.9+ with Bundler, VirtualBox, and Vagrant
already installed. All other dependencies can be installed with Bundler:

  bundle install

The virtual machines are defined and managed with
[Test Kitchen](https://github.com/test-kitchen/test-kitchen). To see all the
supported build platforms:

  bundle exec kitchen list

### Build

To start a full build run of all platforms, just call Test Kitchen:

  bundle exec kitchen test

If you have no need for the VMs, a local build can also be initiated by
running Omnibus directly:

  bin/omnibus build project clamav

Contributing
------------

Pull requests on GitHub are always welcome!

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
