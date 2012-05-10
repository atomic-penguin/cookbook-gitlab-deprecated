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

# Include cookbook dependencies
%w{ gitlab::gitolite sqlite redisio::install redisio::enable build-essential readline python sudo openssh xml zlib }.each do |cb_include|
  include_recipe cb_include
end

# Install required packages for Gitlab
node['gitlab']['packages'].each do |gitlab_pkg|
  package gitlab_pkg
end

# Install sshkey gem into chef
chef_gem "sshkey" do
  action :install
end

# Install required Ruby Gems for Gitlab
%w{ charlock_holmes bundler }.each do |pkg|
  gem_package pkg do
    action :install
  end
end

# Install pygments from pip
python_pip "pygments" do
  action :install
end

# Add the gitlab user
user node['gitlab']['user'] do
  comment "Gitlab User"
  home node['gitlab']['home']
  shell "/bin/bash"
  supports :manage_home => true
end

# Add the gitlab user to the "gitolite" group
group node['gitlab']['git_group'] do
  members node['gitlab']['user']
end

# Create a $HOME/.ssh folder
directory "#{node['gitlab']['home']}/.ssh" do
  owner node['gitlab']['user']
  group node['gitlab']['group']
  mode 0700
end

# Generate and deploy ssh public/private keys
Gem.clear_paths
require 'sshkey'
gitlab_sshkey = SSHKey.generate(:type => 'RSA', :comment => "#{node['gitlab']['user']}@#{node['fqdn']}")
node.set_unless['gitlab']['public_key'] = gitlab_sshkey.ssh_public_key

# Save public_key to node, unless it is already set.
unless Chef::Config[:solo]
  ruby_block "save node data" do
    block do
      node.save
    end
    action :create
  end
end

# Render private key template
template "#{node['gitlab']['home']}/.ssh/id_rsa" do
  owner node['gitlab']['user']
  group node['gitlab']['group']
  variables(
    :private_key => gitlab_sshkey.private_key
  )
  mode 0600
  not_if { File.exists?("#{node['gitlab']['home']}/.ssh/id_rsa") }
end

# Render public key template for gitlab user
template "#{node['gitlab']['home']}/.ssh/id_rsa.pub" do
  owner node['gitlab']['user']
  group node['gitlab']['group']
  mode 0644
end

# Render public key template for gitolite user
template "#{node['gitlab']['git_home']}/gitlab.pub" do
  source "id_rsa.pub.erb"
  owner node['gitlab']['git_user']
  group node['gitlab']['git_group']
  mode 0644
end

template "#{node['gitlab']['home']}/.ssh/config" do
  source "ssh_config.erb"
  owner node['gitlab']['user']
  group node['gitlab']['group']
  mode 0644
end

# Sorry for this, it seems maybe something is wrong with the 'gitolite setup' script.
# This was implemented as a workaround.
execute "install-gitlab-key" do
  command "su - #{node['gitlab']['git_user']} -c 'perl #{node['gitlab']['gitolite_home']}/src/gitolite setup -pk #{node['gitlab']['git_home']}/gitlab.pub'"
  user "root"
  cwd node['gitlab']['git_home']
  not_if "grep -q '#{node['gitlab']['user']}' #{node['gitlab']['git_home']}/.ssh/authorized_keys"
end

# Clone Gitlab repo from github
git "#{node['gitlab']['home']}/app" do
  repository node['gitlab']['repository_url']
  reference "master"
  action :checkout
  user node['gitlab']['user']
  group node['gitlab']['group']
end

# Render config file
template "#{node['gitlab']['home']}/app/config/gitlab.yml" do
  owner node['gitlab']['user']
  group node['gitlab']['group']
  mode 0644
end

# Link example config file to database.yml
link "#{node['gitlab']['home']}/app/config/database.yml" do
  to "#{node['gitlab']['home']}/app/config/database.yml.sqlite"
  owner node['gitlab']['user']
  group node['gitlab']['group']
  link_type :hard
end

if File.exists?("/opt/opscode/embedded/bin/")
  ENV['PATH'] = "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/opscode/bin:/opt/opscode/embedded/bin"
end

# Install Gems with bundle install
execute "gitlab-bundle-install" do
  command "bundle install --without development test --deployment"
  cwd "#{node['gitlab']['home']}/app"
  user node['gitlab']['user']
  environment({ 'LANG' => "en_US.UTF-8", 'LC_ALL' => "en_US.UTF-8" })
  not_if { File.exists?("#{node['gitlab']['home']}/app/vendor/bundle") }
end

# Setup database for Gitlab
execute "gitlab-bundle-rake" do
  command "bundle exec rake gitlab:app:setup RAILS_ENV=production"
  cwd "#{node['gitlab']['home']}/app"
  user node['gitlab']['user'] 
  not_if { File.exists?("#{node['gitlab']['home']}/app/db/production.sqlite3") }
end
