# -*- encoding: utf-8 -*-

name 'libmilter'
default_version '8.14.8'

source url: "ftp://ftp.sendmail.org/pub/sendmail/sendmail.#{version}.tar.gz",
       md5: '73bfc621c75dbdd3d719e54685d92577'

relative_path "sendmail-#{version}/libmilter"

prefix = "#{install_dir}/embedded"
libdir = "#{prefix}/lib"

require 'etc'

user = Etc.getlogin
env = {
  'LDFLAGS' => "-L#{libdir} -I#{prefix}/include",
  'CFLAGS' => "-L#{libdir} -I#{prefix}/include -fPIC",
  'LD_RUN_PATH' => libdir
}

build do
  command [
    './Build install',
    "DESTDIR=#{prefix}",
    "INCOWN=#{user}",
    "INCGRP=#{user}",
    "LIBOWN=#{user}",
    "LIBGRP=#{user}",
    'INCLUDEDIR=/include/',
    'LIBDIR=/lib/'
  ].join(' '), env: env
end
