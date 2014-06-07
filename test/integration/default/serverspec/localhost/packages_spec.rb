# Encoding: UTF-8

require 'spec_helper'

describe 'clamav Omnibus package' do
  it 'is installed' do
    expect(package('clamav')).to be_installed
  end
end
