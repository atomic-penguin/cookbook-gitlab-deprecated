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
%w{ git gitolite sqlite redisio::install redisio::enable build-essential readline sudo openssh xml zlib }.each do |cb_include|
  include_recipe cb_include
end

# Install required packages for Gitlab
node['gitlab']['packages'].each do |gitlab_pkg|
  package gitlab_pkg
end

# Install required Ruby Gems for Gitlab
%w{ charlock_holmes bundler sshkey }.each do |pkg|
  gem_package pkg do
    action :install
    ignore_failure true
  end
end

# Add the gitlab user
user node['gitlab']['user'] do
  comment "Gitlab User"
  home node['gitlab']['home']
  shell "/bin/bash"
  supports :manage_home => true
end

# Add the gitlab user to the "gitolite" group
group node['gitolite']['security_group'] do
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
gitlab_sshkey = SSHKey.generate(:type => 'RSA', :bits => 1024, :comment => "#{node['gitlab']['user']}@#{node['fqdn']}")
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
template "#{node['gitolite']['git_home']}/gitlab.pub" do
  owner node['gitolite']['admin_name']
  group node['gitolite']['security_group']
  mode 0644
end

# Sorry for this, it seems maybe something is wrong with the 'gitolite setup' script.
# This was implemented as a workaround.
execute "install-gitolite-admin-key" do
  command "su - #{node['gitolite']['admin_name']} -c 'perl #{node['gitolite']['gitolite_home']}/src/gitolite setup -pk #{node['gitolite']['git_home']}/gitlab.pub'"
  user "root"
  cwd node['gitolite']['gitolite_home']
  not_if { grep -q "'#{node['gitlab']['user']}' #{node['gitolite']['gitolite_home']}/.ssh/authorized_keys" }
end

# Clone Gitlab repo from github
git node['gitlab']['gitlab_home'] do
  repository node['gitlab']['repository_url']
  reference "master"
  action :checkout
  user node['gitlab']['user']
  group node['gitlab']['group']
end

# Link example config file to gitlab.yml
link "#{node['gitlab']['home']}/config/gitlab.yml" do
  to "#{node['gitlab']['home']}/config/gitlab.yml.example"
  owner node['gitlab']['user']
  group node['gitlab']['group']
  link_type :hard
  not_if { File.exists?("#{node['gitlab']['home']}/config/gitlab.yml") }
end

# Link example config file to database.yml
link "#{node['gitlab']['home']}/config/database.yml" do
  to "#{node['gitlab']['home']}/config/database.yml.sqlite"
  owner node['gitlab']['user']
  group node['gitlab']['group']
  link_type :hard
  not_if { File.exists?("#{node['gitlab']['home']}/config/database.yml") }
end

# Install Gems with bundle install
execute "gitlab-bundle-install" do
  command "su - #{node['gitlab']['gitlab_user']} -c \"cd #{node['gitlab']['gitlab_home']}/gitlab; /opt/opscode/embedded/bin/bundle install --without development test --deployment\""
  cwd "#{node['gitlab']['gitlab_home']}/gitlab"
  user "root"
  group "root"
  action :run
  only_if "test -d /opt/opscode/embedded/bin"
  not_if "test -d #{node['gitlab']['gitlab_home']}/gitlab/db"
end

# Setup database for Gitlab
execute "gitlab-bundle-exec-rake" do
  command "su - #{node['gitlab']['gitlab_user']} -c \"PATH=$PATH:/opt/opscode/embedded/bin;
           cd #{node['gitlab']['gitlab_home']}/gitlab;
           /opt/opscode/embedded/bin/bundle exec rake gitlab:app:setup RAILS_ENV=production\""
  cwd "#{node['gitlab']['gitlab_home']}/gitlab"
  user "root"
  group "root"
  action :run
  only_if "test -d /opt/opscode/embedded/bin"
  not_if "test -d #{node['gitlab']['gitlab_home']}/gitlab/db"
end

# Start Gitlab Rails app
execute "start-gitlab-rails-app" do
  command "su - #{node['gitlab']['gitlab_user']} -c \"PATH=$PATH:/opt/opscode/embedded/bin;
           cd #{node['gitlab']['gitlab_home']}/gitlab;
           bundle exec rails s -e production -d\""
  cwd "#{node['gitlab']['gitlab_home']}/gitlab"
  user "root"
  group "root"
  action :run
  only_if "test -d /opt/opscode/embedded/bin"
  not_if "ps aux |grep gitlab |grep 'rails s -e production' |egrep -v grep"
end

# Start Resque for queue processing
execute "start-resque-for-queue-processing" do
  command "su - #{node['gitlab']['gitlab_user']} -c \"PATH=$PATH:/opt/opscode/embedded/bin;
           cd #{node['gitlab']['gitlab_home']}/gitlab;
           ./resque.sh &\""
  cwd "#{node['gitlab']['gitlab_home']}/gitlab"
  user "root"
  group "root"
  action :run
  only_if "test -d /opt/opscode/embedded/bin"
  not_if "ps aux |grep resque |egrep -v grep"
end
