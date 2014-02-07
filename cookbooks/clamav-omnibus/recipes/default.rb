# -*- encoding: utf-8 -*-
#
# Cookbook Name:: clamav-omnibus
# Recipe:: default
#
# Copyright 2014, Jonathan Hartman
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'omnibus'

file '/root/omnibus_build_complete' do
  content "# This file was created by Chef for #{node['fqdn']}"
  action :nothing
end

execute 'Run Omnibus builder' do
  command <<-OMNIBUS_BUILD
    export PATH=/usr/local/bin:$PATH
    cd #{node['omnibus']['build_dir']} && \
    su #{node['omnibus']['build_user']} -c "bundle install --binstubs" && \
    su #{node['omnibus']['build_user']} \
      -c "bin/omnibus build project #{node['omnibus']['project_name']}"
  OMNIBUS_BUILD
  not_if { File.exist?('/root/omnibus_build_complete') }
end

# Clean up the Omnibus artifacts in preparation for package install
directory node['omnibus']['install_dir'] do
  recursive true
  action :delete
  not_if { File.exist?('/root/omnibus_build_complete') }
  notifies :create, 'file[/root/omnibus_build_complete]'
end

# Install the Omnibus package artifact
case node['platform_family']
when 'rhel'
  pkg = "#{node['omnibus']['project_name']}-" \
        "#{node['omnibus']['project_version']}-" \
        "#{node['omnibus']['project_build']}.el" \
        "#{node['platform_version'].to_i}.x86_64.rpm"
when 'debian'
  pkg = "#{node['omnibus']['project_name']}_" \
        "#{node['omnibus']['project_version']}-" \
        "#{node['omnibus']['project_build']}." \
        "#{node['platform']}.#{node['platform_version']}_amd64.deb"
end

package File.join(node['omnibus']['build_dir'], 'pkg', pkg) do
  provider(
    case node['platform_family']
    when 'rhel'
      Chef::Provider::Package::Rpm
    when 'debian'
      Chef::Provider::Package::Dpkg
    else
      fail 'Unsupported platform'
    end
  )
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby
