# Encoding: UTF-8
#
# Cookbook Name:: clamav-omnibus
# Recipe:: build
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

include_recipe 'apt' if node['platform_family'] == 'debian'
include_recipe 'omnibus'

touch_when_complete = '/root/omnibus_build_complete'

file touch_when_complete do
  content node['omnibus']['artifact_file']
  action :nothing
end

ruby_block 'chown -r the build dir' do
  # Otherwise we end up with garbage like /home/omnibus/clamav owned by vagrant
  block do
    require 'fileutils'
    FileUtils.chown_R(node['omnibus']['build_user'],
                      node['omnibus']['build_user_group'],
                      node['omnibus']['build_dir'])
  end
end

execute 'Install bundled Gems' do
  # The execute resource's `user` method doesn't allocate a TTY, doesn't pull
  # in all the environment variables Bundler and Omnibus need to run,
  # hence the hackery here
  user node['omnibus']['build_user']
  cwd node['omnibus']['build_dir']
  env 'HOME' => node['omnibus']['build_user_home']
  command <<-OMNIBUS_BUILD
    chruby-exec #{node['omnibus']['ruby_version']} -- bundle install \
      --binstubs --without=control_node --path .bundle
  OMNIBUS_BUILD
end

# Run the build using Mixlib::ShellOut directly so we can enable live output
# and keep "idle builds" from being incorrectly killed off
ruby_block 'Run Omnibus build' do
  block do
    command = <<-OMNIBUS_BUILD
      chruby-exec #{node['omnibus']['ruby_version']} -- bundle exec \
        bin/omnibus build #{node['omnibus']['project_name']} -l debug
    OMNIBUS_BUILD

    require 'mixlib/shellout'
    Mixlib::ShellOut.new(command,
                         user: node['omnibus']['build_user'],
                         cwd: node['omnibus']['build_dir'],
                         env: { 'HOME' => node['omnibus']['build_user_home'] },
                         live_stream: STDOUT).run_command
  end
  not_if { File.exist?(touch_when_complete) }
end

# Clean up the Omnibus artifacts in preparation for package install
directory node['omnibus']['install_dir'] do
  recursive true
  action :delete
  not_if { File.exist?(touch_when_complete) }
end

# Install the Omnibus package artifact
package node['omnibus']['artifact'] do
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
  notifies :create, "file[#{touch_when_complete}]"
end
