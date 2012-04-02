#
# Cookbook Name:: gitlab
# Recipe:: default
#
# Copyright 2012, Marshall University
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

# Install git
include_recipe "git"

# Install gitolite
include_recipe "gitolite"

# Create gitlab user
user node['gitlab']['gitlab_user_name'] do
  comment node['gitlab']['gitlab_user_comment']
  home node['gitlab']['gitlab_user_home_dir']
  shell node['gitlab']['gitlab_user_default_shell']
  password node['gitlab']['gitlab_user_password']
end

# Create user gitlab's home directory
directory node['gitlab']['gitlab_user_home_dir'] do
  owner node['gitlab']['gitlab_user_name']
  group node['gitlab']['gitlab_user_group_name']
  mode node['gitlab']['gitlab_user_mode']
end

# Add user gitlab to ['gitolite']['git_user_group_name']
git_user = node['gitolite']['git_user_name']
gitlab_user = node['gitlab']['gitlab_user_name']

group node['gitolite']['git_user_group_name'] do
  members ["#{git_user}","#{gitlab_user}"]
end
