# -*- encoding: utf-8 -*-

require 'spec_helper'

describe 'clamav Omnibus package' do
  it 'is installed' do
    expect(package('clamav')).to be_installed
  end
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby
