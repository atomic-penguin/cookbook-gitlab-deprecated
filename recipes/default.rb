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

# Generate ssh key pair for gitlab user
execute "generate-ssh-keypairs" do
  command "mkdir #{node['gitlab']['gitlab_user_home_dir']}/.ssh;
           ssh-keygen -q -f #{node['gitlab']['gitlab_user_home_dir']}/.ssh/id_rsa -N \"\";
           chown -R #{node['gitlab']['gitlab_user_name']}:#{node['gitlab']['gitlab_user_group_name']} #{node['gitlab']['gitlab_user_home_dir']}/.ssh"
  user node['gitlab']['gitlab_user_name']
  group node['gitlab']['gitlab_user_group_name']
  cwd node['gitlab']['gitlab_user_home_dir']
  action :run
  #not_if {File.exist? "#{node['gitlab']['gitlab_user_home_dir']}/.ssh/id_rsa.pub"}
end

# Copy public key to  authorized_keys
execute "cp_gitlab_public_key_to_authorized_keys" do 
  command "cp #{node['gitlab']['gitlab_user_home_dir']}/.ssh/id_rsa.pub #{node['gitlab']['gitlab_user_home_dir']}/.ssh/authorized_keys"
  user node['gitlab']['gitlab_user_name']
  group node['gitlab']['gitlab_user_group_name']
  cwd node['gitlab']['gitlab_user_home_dir']
  action :run
  #not_if {File.exist? "#{node['gitlab']['gitlab_user_home_dir']}/.ssh/authorized_keys"}
end

# Copy user gitlab's public key to /home/git
execute "cp_gitlab_public_key " do
  command "cp #{node['gitlab']['gitlab_user_home_dir']}/.ssh/id_rsa.pub #{node['gitolite']['git_user_home_dir']}/gitlab.pub;
           chmod 777 #{node['gitolite']['git_user_home_dir']}/gitlab.pub;
           chown #{node['gitolite']['git_user_name']}:#{node['gitolite']['git_user_group_name']} #{node['gitolite']['git_user_home_dir']}/gitlab.pub;
           gitolite setup -pk /home/git/gitlab.pub"
  user node['gitolite']['gitolite_user_name']
  group node['gitolite']['gitolite_user_group_name']
  cwd node['gitolite']['gitolite_user_home_dir']
  action :run
  #not_if {File.exist? "#{node['gitolite']['git_user_home_dir']}/gitlab.pub"}
  #not_if "stat -c %a #{node['gitolite']['git_user_home_dir']}/gitlab.pub |grep 777"
end

directory node['gitolite']['git_user_home_dir'] do
  owner node['gitolite']['git_user_name']
  group node['gitolite']['git_user_group_name']
  mode "0775"
end
