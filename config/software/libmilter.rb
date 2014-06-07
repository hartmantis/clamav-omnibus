# Encoding: UTF-8

name 'libmilter'
default_version '8.14.9'

source url: "ftp://ftp.sendmail.org/pub/sendmail/sendmail.#{version}.tar.gz",
       md5: '6a3bdceffa592316f830be289a4bd783'

relative_path "sendmail-#{version}/libmilter"

prefix = "#{install_dir}/embedded"
libdir = "#{prefix}/lib"

require 'etc'

user = Etc.getpwuid(Process.uid).name
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
