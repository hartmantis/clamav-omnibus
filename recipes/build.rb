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

cookbook_path = File.join('/tmp/kitchen/cookbooks', cookbook_name.to_s)

ruby_block 'copy_everything_to_build_dir' do
  block do
    # Put everything in /home/omnibus to bypass issues with the contents of
    # /tmp/kitchen being owned by root
    require 'fileutils'
    FileUtils.rm_rf(node['omnibus']['build_dir'])
    FileUtils.cp_r(cookbook_path, node['omnibus']['build_dir'])
    FileUtils.chown_R(node['omnibus']['build_user'],
                      node['omnibus']['build_user_group'],
                      node['omnibus']['build_dir'])
  end
  not_if { File.exist?(touch_when_complete) }
end

# TODO: Installing and using the Chef-DK here might save a bunch of time
execute 'Install bundled Gems' do
  # The execute resource's `user` method doesn't allocate a TTY, doesn't pull
  # in all the environment variables Bundler and Omnibus need to run,
  # otherwise we'd use `user`, `group`, and `cwd` for these
  command <<-OMNIBUS_BUILD
    su - #{node['omnibus']['build_user']} -c \
      'cd #{node['omnibus']['build_dir']} && \
      bundle install --binstubs --without=control_node'
  OMNIBUS_BUILD
end

ruby_block 'Run Omnibus build' do
  block do
    command = <<-OMNIBUS_BUILD
      su - #{node['omnibus']['build_user']} -c \
        'cd #{node['omnibus']['build_dir']} && \
        bin/omnibus build #{node['omnibus']['project_name']} -l info'
    OMNIBUS_BUILD

    require 'mixlib/shellout'
    Mixlib::ShellOut.new(command, live_stream: STDOUT).run_command
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
