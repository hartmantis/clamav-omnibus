# Encoding: UTF-8

name 'clamav'
default_version '0.98.3'

dependency 'bzip2'
dependency 'curl'
dependency 'libmilter'
dependency 'libtool'
dependency 'ncurses'
dependency 'openssl'
dependency 'zlib'

source url: 'http://downloads.sourceforge.net/project/clamav/clamav/0.98.3/' \
            'clamav-0.98.3.tar.gz?r=&ts=1399495935&use_mirror=softlayer-dal',
       md5: 'b649d35ee85d4d6075a98173dd255c17'

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
    "--with-openssl=#{install_dir}/embedded",
    "--with-zlib=#{install_dir}/embedded",
    "--with-xml=#{install_dir}/embedded",
    "--with-libncurses-prefix=#{install_dir}/embedded",
    "--with-dbdir=#{install_dir}/db"
  ].join(' '), env: env

  command 'make check', env: env
  command "make -j #{max_build_jobs}", env: env
  command 'make install'
  command "mkdir -p #{install_dir}/db"
  %w(main.cvd daily.cvd bytecode.cvd safebrowsing.cvd).each do |f|
    command "wget -P #{install_dir}/db/ http://db.local.clamav.net/#{f}"
  end
  command "mkdir -p #{install_dir}/init.d"
  %w(clamd freshclam).each do |f|
    command "cp #{Omnibus.project_root}/init.d/#{f}.init." \
            "#{Ohai.platform_family} #{install_dir}/init.d/#{f}"
  end
end
