# Encoding: UTF-8
#
# Cookbook Name:: clamav-omnibus
# Attributes:: default
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

# The user under whom the package repo exists
default['package_cloud']['user'] = nil
# The token of the user above or another user that has commit privileges
default['package_cloud']['token'] = nil

case node['platform_family']
when 'rhel'
  pkg = "#{node['omnibus']['project_name']}-" \
        "#{node['omnibus']['project_version']}-" \
        "#{node['omnibus']['project_build']}.el" \
        "#{node['platform_version'].to_i}.x86_64.rpm"
when 'debian'
  pkg = "#{node['omnibus']['project_name']}_" \
        "#{node['omnibus']['project_version']}-" \
        "#{node['omnibus']['project_build']}_amd64.deb"
end
default['omnibus']['artifact'] = File.join(node['omnibus']['build_dir'], 'pkg',
                                           pkg)
