#
# Cookbook Name:: gitlab
# Recipe:: postgres
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

include_recipe 'postgresql::server'
include_recipe 'database::postgresql'

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

# Create the database user
postgresql_database_user node['gitlab']['database']['username'] do
  connection :host => 'localhost'
  password node['gitlab']['database']['password']
  action :create
end

# Create the database
postgresql_database node['gitlab']['database']['database'] do
  connection :host => 'localhost'
  owner node['gitlab']['database']['username']
  action :create
end

# FIXME: Add extension resource to postgresql cookbook
node.force_override['postgresql']['database_name'] = node['gitlab']['database']['database']
include_recipe 'postgresql::contrib'
