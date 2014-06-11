clamav Omnibus project
======================
[![Build Status](http://img.shields.io/travis/RoboticCheese/clamav-omnibus.svg)][travis]

[travis]: http://travis-ci.org/RoboticCheese/clamav-omnibus

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
project, driven by [Test Kitchen](https://github.com/test-kitchen/test-kitchen)
to spawn build machines for each supported distro.

To get started, you must have Ruby 1.9+ with Bundler. If you intend to use
Vagrant and VirtualBox for the build environment, those applications must
already be installed as well. All other dependencies can be installed with
Bundler:

    bundle install

To see all the supported build platforms:

    bundle exec kitchen list

This project defines a set of Rake tasks for any or all nodes, to perform
either a Kitchen converge + verify (build the packages and test them) or a
converge + verify + deploy (build the packages, test them, and publish them to
the package repo).

### Wait, what?

This project deviates from other Omnibus projects in some ways:

* It removes all dependencies that Omnibus has on Vagrant, to allow for builds
  on cloud servers. Because only the Vagrant driver is able to do two-way
  directory syncing, this leaves us without an easy way to pull package
  artifacts back down off the VMs. But, that's not necessarily a problem
  because...
* It automates delivery of the artifacts to a package repo once they're built
  and verified.

### PackageCloud

At least to start, [PackageCloud.io](http://packagecloud.io) is being used as
the artifact repository. This was borne out of a set of requirements other
repositories don't seem to support:

* GitHub Releases - A release in GitHub can contain multiple artifact files,
  but all at the same directory level. Meanwhile, Omnibus has moved toward no
  longer putting OS versions into package names (i.e. packages for all versions
  of Ubuntu are now given the same filename). We need an artifact repository
  with a directory structure.
* BinTray - This is the service used to distribute Vagrant packages. It appears
  much further in development than PackageCloud, but institutes a package size
  limit of 50MB. Each ClamAV package contains 67MB of virus definitions and
  weighs in at over 100MB altogether.
* Amazon EC2 - This is where Chef hosts their packages and is a fine option,
  but the alternatives are free.

### Build

To start a full build run of all platforms, just call Test Kitchen:

    rake kitchen:all

To start a full build run and publish the resulting artifacts:

    rake

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
