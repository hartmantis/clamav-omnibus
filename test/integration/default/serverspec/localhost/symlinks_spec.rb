# Encoding: UTF-8

require 'spec_helper'

{
  '/etc/clamav' => '/opt/clamav/etc',
  '/etc/init.d/clamd' => '/opt/clamav/init.d/clamd',
  '/etc/init.d/freshclam' => '/opt/clamav/init.d/freshclam',
  '/usr/bin/clamav-config' => '/opt/clamav/bin/clamav-config',
  '/usr/bin/clambc' => '/opt/clamav/bin/clambc',
  '/usr/bin/clamconf' => '/opt/clamav/bin/clamconf',
  '/usr/bin/clamdscan' => '/opt/clamav/bin/clamdscan',
  '/usr/bin/clamdtop' => '/opt/clamav/bin/clamdtop',
  '/usr/bin/clamscan' => '/opt/clamav/bin/clamscan',
  '/usr/bin/clamsubmit' => '/opt/clamav/bin/clamsubmit',
  '/usr/bin/freshclam' => '/opt/clamav/bin/freshclam',
  '/usr/bin/sigtool' => '/opt/clamav/bin/sigtool',
  '/usr/sbin/clamav-milter' => '/opt/clamav/sbin/clamav-milter',
  '/usr/sbin/clamd' => '/opt/clamav/sbin/clamd'
}.each do |l, f|
  describe "clamav Omnibus symlink #{l}" do
    it "links to #{f}" do
      expect(file(l)).to be_linked_to(f)
    end
  end
end
