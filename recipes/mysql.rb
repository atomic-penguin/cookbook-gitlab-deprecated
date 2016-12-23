#
# Cookbook Name:: gitlab
# Recipe:: mysql
#
# Copyright 2012, Seth Vargo
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
mysql2_chef_gem 'default' do
  client_version node['mysql']['version'] if node['mysql'] && node['mysql']['version']
  action :install
end

# Enable secure password generation
unless node['gitlab']['database']['password']
  require 'securerandom'
  pw = SecureRandom.urlsafe_base64
  node.normal['gitlab']['database']['password'] = pw

  unless Chef::Config[:solo]
    node2 = Chef::Node.load node.name
    node2.normal['gitlab']['database']['password'] = pw
    node2.save
  end
end

# install mysql database
mysql_service 'default' do
  port '3306'
  version node['mysql']['version'] if node['mysql'] && node['mysql']['version']
  initial_root_password node['mysql']['server_root_password']
  action [:create, :start]
end

# Helper variables
database = node['gitlab']['database']['database']
database_user = node['gitlab']['database']['username']
database_password = node['gitlab']['database']['password']
database_userhost = node['gitlab']['database']['userhost']
database_host = node['gitlab']['database']['host']
database_host = node['gitlab']['database']['socket']
database_connection = {
  host: database_host,
  username: 'root',
  password: node['mysql']['server_root_password'],
  socket: node['mysql']['socket']
}

# Create the database
mysql_database database do
  connection database_connection
  action :create
end

# Create the database user
mysql_database_user database_user do
  connection database_connection
  password database_password
  host database_userhost
  database_name database
  action :create
end

# Grant all privileges to user on database
mysql_database_user database_user do
  connection database_connection
  database_name database
  privileges ['SELECT', 'LOCK TABLES', 'INSERT', 'UPDATE', 'DELETE', 'CREATE', 'DROP', 'INDEX', 'ALTER']
  action :grant
end
