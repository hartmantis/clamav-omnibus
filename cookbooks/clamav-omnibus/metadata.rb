# -*- encoding: utf-8 -*-

name              'clamav-omnibus'
maintainer        'Jonathan Hartman'
maintainer_email  'j@p4nt5.com'
license           'Apache v2.0'
description       'Builds ClamAV Omnibus packages'
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           '0.1.0'

depends           'omnibus'

supports          'ubuntu', '>= 10.04'
supports          'redhat', '>= 5.0'
supports          'centos', '>= 5.0'
supports          'scientific', '>= 5.0'
supports          'amazon', '>= 5.0'

# vim: ai et ts=2 sts=2 sw=2 ft=ruby
