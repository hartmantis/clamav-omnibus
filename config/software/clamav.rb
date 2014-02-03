# -*- encoding: utf-8 -*-

name 'clamav'
version '0.98.1'

dependency 'zlib'
dependency 'bzip2'
dependency 'libtool'
dependency 'ncurses'
dependency 'libmilter'

source url: 'http://downloads.sourceforge.net/project/clamav/clamav/0.98.1/' \
            'clamav-0.98.1.tar.gz?r=&ts=1391302102&use_mirror=softlayer-dal',
       md5: 'b1ec7b19dea8385954515ef1d63576d8'

relative_path "#{name}-#{version}"

env = {
  'LDFLAGS' => "-L#{install_dir}/embedded/lib " \
               "-I#{install_dir}/embedded/include",
  'CFLAGS' => "-L#{install_dir}/embedded/lib " \
              "-I#{install_dir}/embedded/include",
  'CPPFLAGS' => "-L#{install_dir}/embedded/lib " \
                "-I#{install_dir}/embedded/include",
  'LIBS' => '-ltinfo',
  'LD_RUN_PATH' => "#{install_dir}/embedded/lib"
}

build do
  command [
    './configure',
    "--prefix=#{install_dir}/embedded",
    "--bindir=#{install_dir}/bin",
    "--sbindir=#{install_dir}/sbin",
    "--libdir=#{install_dir}/embedded/lib",
    "--sysconfdir=#{install_dir}/etc",
    '--disable-debug',
    '--disable-dependency-tracking',
    '--enable-ipv6',
    '--enable-milter',
    '--enable-clamdtop',
    '--disable-clamav',
    '--with-user=clamav',
    '--with-group=clamav',
    "--with-zlib=#{install_dir}/embedded",
    "--with-xml=#{install_dir}/embedded",
    "--with-libncurses-prefix=#{install_dir}/embedded",
    "--with-dbdir=#{install_dir}/db"
  ].join(' '), env: env

  command 'make check', env: env
  command "make -j #{max_build_jobs}", env: env
  command 'make install'
  %w{main.cvd daily.cvd bytecode.cvd safebrowsing.cvd}.each do |f|
    command "wget -P #{install_dir}/db/ http://db.local.clamav.net/#{f}"
  end
end
