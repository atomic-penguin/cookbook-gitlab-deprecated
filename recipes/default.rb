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
%w{ charlock_holmes bundler }.each do |pkg|
  gem_package pkg do
  action :install
  ignore_failure true
  end
end

# Clone Gitlab repo from github
git "#{node['gitlab']['gitlab_home']}/gitlab" do
  repository node['gitlab']['repository_url']
  reference "master"
  action :sync
  user node['gitlab']['gitlab_user']
  group node['gitlab']['gitlab_group']
  not_if "test -d #{node['gitlab']['gitlab_home']}/gitlab"
end

# Rename config file to gitlab.yml
execute "rename-gitlab.yml" do
  command "su - #{node['gitlab']['gitlab_user']} -c \"cp #{node['gitlab']['gitlab_home']}/gitlab/config/gitlab.yml.example #{node['gitlab']['gitlab_home']}/gitlab/config/gitlab.yml\""
  cwd "#{node['gitlab']['gitlab_home']}/gitlab"
  user "root" 
  group "root"
  action :run
  not_if "test -f #{node['gitlab']['gitlab_home']}/gitlab/config/gitlab.yml"
end

# Rename config file to database.yml
execute "rename-database.yml" do
  command "su - #{node['gitlab']['gitlab_user']} -c \"cp #{node['gitlab']['gitlab_home']}/gitlab/config/database.yml.sqlite #{node['gitlab']['gitlab_home']}/gitlab/config/database.yml\""
  cwd "#{node['gitlab']['gitlab_home']}/gitlab"
  user "root"
  group "root"
  action :run
  not_if "test -f #{node['gitlab']['gitlab_home']}/gitlab/config/database.yml"
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
