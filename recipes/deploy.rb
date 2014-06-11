# Encoding: UTF-8
#
# Cookbook Name:: clamav-omnibus
# Recipe:: deploy
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

# TODO: Sugar isn't being included in the ruby_gem resource
include_recipe 'chef-sugar'

# TODO: Robustify this and make a separate package_cloud cookbook
ruby_gem 'package_cloud' do
  ruby node['omnibus']['ruby_version']
end

# The chruby.sh script contains what are syntax errors to sh; we need bash here
# instead of an execute resource
bash 'Push Omnibus artifact to PackageCloud repo' do
  user = node['packagecloud']['user']
  repo = node['omnibus']['project_name']
  distro = case node['platform_family']
           when 'rhel'
             "el/#{node['platform_version'].to_i}"
           else
             "#{node['platform']}/#{node['lsb']['codename']}"
           end
  environment(
    'PACKAGECLOUD_TOKEN' => node['packagecloud']['token'],
    # TODO: The encoding only needs to be set here because, otherwise,
    # package_cloud ends up expecting ASCII and erroring when the API throws
    # back non-ASCII characters in its JSON responses
    'LC_ALL' => 'en_US.UTF-8'
  )
  code <<-EOH
    source /usr/local/share/chruby/chruby.sh && \
    chruby #{node['omnibus']['ruby_version']} && \
    package_cloud push #{user}/#{repo}/#{distro} #{node['omnibus']['artifact']}
  EOH
end
