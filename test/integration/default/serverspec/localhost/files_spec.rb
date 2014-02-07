# -*- encoding: utf-8 -*-

require 'spec_helper'

%w{
  /opt/clamav/etc/clamd.conf
  /opt/clamav/etc/freshclam.conf
}.each do |f|
  describe "clamav Omnibus file #{f}" do
    it 'is created' do
      pending 'Config files not quite decided yet'
      expect(file(d)).to be_file
    end
  end
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby
