# -*- encoding: utf-8 -*-

require 'spec_helper'

%w{
  /opt/clamav
  /opt/clamav/etc
  /opt/clamav/init.d
}.each do |d|
  describe "clamav Omnibus directory #{d}" do
    it 'is created' do
      expect(file(d)).to be_directory
    end
  end
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby
