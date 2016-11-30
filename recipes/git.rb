#
# Cookbook Name:: gitlab
# Recipe:: git
#
# Copyright 2016, Yakara Ltd
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

git_recipe = node['gitlab']['git_recipe']

yum_repository 'endpoint-git' do
  description 'git from End Point repository'
  includepkgs 'git git-core* perl-Git'
  el = node['platform_version'].to_i
  baseurl "https://packages.endpoint.com/rhel/#{el}/os/$basearch/"
  gpgkey "https://packages.endpoint.com/endpoint-rpmsign-#{el}.pub"
  only_if { git_recipe == 'package' && platform_family?('rhel') }
end

include_recipe "git::#{git_recipe}"
