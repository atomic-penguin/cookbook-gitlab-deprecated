#
# Cookbook Name:: gitlab
# Attributes:: default 
#
# Copyright 2012, Gerald L. Hevener Jr., M.S.
# Copyright 2012, Eric G. Wolfe
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

# Set attributes for the git user
default['gitlab']['user'] = "gitlab"
default['gitlab']['group'] = "gitlab"
default['gitlab']['home'] = "/var/gitlab"

# Set github URL for gitlab
default['gitlab']['repository_url'] = "git://github.com/gitlabhq/gitlabhq.git"

# Required packages for Gitlab
case node['platform']
when "ubuntu","debian","linuxmint"
  default['gitlab']['packages'] = %w{ ruby1.9.1 ruby1.9.1-dev ruby1.9.1-full rubygems curl wget checkinstall libxslt-dev libsqlite3-dev libcurl4-openssl-dev libssl-dev libmysql++-dev libicu-dev libc6-dev libyaml-dev nginx }
when "redhat","centos","amazon","scientific"
  default['gitlab']['packages'] = %w{ curl wget libxslt-devel sqlite-devel openssl-devel mysql++-devel libicu-devel glibc-devel libyaml-devel nginx } 
end

default['gitlab']['trust_local_sshkeys'] = "yes"
