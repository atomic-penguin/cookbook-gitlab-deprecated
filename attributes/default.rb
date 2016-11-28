#
# Cookbook Name:: gitlab
# Attributes:: default
#
# Copyright 2012, Gerald L. Hevener Jr., M.S.
# Copyright 2012, Eric G. Wolfe
# Copyright 2013, Johannes Becker
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
default['gitlab']['user'] = 'git'
default['gitlab']['group'] = 'git'
default['gitlab']['home'] = '/srv/git'
default['gitlab']['app_home'] = default['gitlab']['home'] + '/gitlab'
default['gitlab']['web_fqdn'] = node['fqdn']
default['gitlab']['nginx_server_names'] = ['gitlab.*', node['fqdn']]
default['gitlab']['email_from'] = "gitlab@#{node['domain']}"
default['gitlab']['support_email'] = "gitlab-support@#{node['domain']}"
default['gitlab']['unicorn']['timeout'] = 60

# User default privileges
default['gitlab']['default_projects_limit'] = 10
default['gitlab']['default_can_create_group'] = true
default['gitlab']['username_changing_enabled'] = true

# Set github URL for gitlab
default['gitlab']['git_url'] = 'https://github.com/gitlabhq/gitlabhq.git'
default['gitlab']['git_branch'] = '8-5-stable'

# gitlab-shell attributes
default['gitlab']['shell']['home'] = node['gitlab']['home'] + '/gitlab-shell'
default['gitlab']['shell']['git_url'] = 'https://github.com/gitlabhq/gitlab-shell.git'
default['gitlab']['shell']['git_branch'] = 'v2.6.10'
default['gitlab']['shell']['gitlab_host'] = nil

# Database setup
default['gitlab']['database']['type'] = 'mysql'
default['gitlab']['database']['adapter'] = node['gitlab']['database']['type'] == 'mysql' ? 'mysql2' : 'postgresql'
default['gitlab']['database']['encoding'] = node['gitlab']['database']['type'] == 'mysql' ? 'utf8' : 'unicode'
default['gitlab']['database']['collation'] = 'utf8_general_ci'
default['gitlab']['database']['host'] = '127.0.0.1'
default['gitlab']['database']['socket'] = '/var/run/mysql-default/mysqld.sock'
default['gitlab']['database']['pool'] = 5
default['gitlab']['database']['database'] = 'gitlab'
default['gitlab']['database']['username'] = 'gitlab'
default['gitlab']['database']['userhost'] = '127.0.0.1'
default['gitlab']['postgresql']['username'] = 'postgres'
default['gitlab']['database']['password'] = nil

# Ruby setup
include_attribute 'ruby_build'
default['ruby_build']['upgrade'] = 'sync'
default['gitlab']['install_ruby'] = '2.1.8'
default['gitlab']['install_ruby_path'] = node['gitlab']['home']
default['gitlab']['cookbook_dependencies'] = %w(
  zlib
  readline
  ncurses
  openssh
  logrotate
  redisio::default
  redisio::enable
  ruby_build
)

# Redisio instance name
default['gitlab']['redis_instance'] = 'redis-server'

# Required packages for Gitlab
default['gitlab']['packages'] = %w(
  cmake
  curl
  golang
  nodejs
  python-docutils
  sudo
  wget
)
case node['platform_family']
when 'debian'
  default['gitlab']['packages'] += %w(
    checkinstall
    libcurl4-openssl-dev
    libffi-dev
    libgdbm-dev
    libicu-dev
    libkrb5-dev
    libssl-dev
    libyaml-dev
    pkg-config
  )
when 'rhel'
  default['gitlab']['packages'] += %w(
    gdbm-devel
    jemalloc
    jemalloc-devel
    krb5-devel
    libcurl-devel
    libffi-devel
    libicu-devel
    libyaml-devel
    openssl-devel
    pkgconfig
  )
end

default['gitlab']['trust_local_sshkeys'] = 'yes'

default['gitlab']['https'] = false
default['gitlab']['certificate_databag_id'] = nil
default['gitlab']['self_signed_cert'] = false
default['gitlab']['ssl_certificate'] = "/etc/nginx/ssl/certs/#{node['fqdn']}.pem"
default['gitlab']['ssl_certificate_key'] = "/etc/nginx/ssl/private/#{node['fqdn']}.key"

# Backwards compatible ciphers needed for Java IDEs
default['gitlab']['ssl_ciphers'] = 'ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4'
default['gitlab']['ssl_protocols'] = 'TLSv1 TLSv1.1 TLSv1.2'

default['gitlab']['backup_path'] = node['gitlab']['app_home'] + '/backups'
default['gitlab']['backup_keep_time'] = 604_800

# Ip and port nginx will be serving requests on
default['gitlab']['listen_ip'] = '*'
default['gitlab']['listen_port'] = nil

# LDAP authentication
default['gitlab']['ldap']['enabled'] = false
default['gitlab']['ldap']['host'] = '_your_ldap_server'
default['gitlab']['ldap']['base'] = '_the_base_where_you_search_for_users'
default['gitlab']['ldap']['port'] = 636
default['gitlab']['ldap']['active_directory'] = true
default['gitlab']['ldap']['uid'] = 'sAMAccountName'
default['gitlab']['ldap']['method'] = 'ssl'
default['gitlab']['ldap']['bind_dn'] = '_the_full_dn_of_the_user_you_will_bind_with'
default['gitlab']['ldap']['password'] = '_the_password_of_the_bind_user'
default['gitlab']['ldap']['allow_username_or_email_login'] = true
default['gitlab']['ldap']['user_filter'] = ''

# Secrets
default['gitlab']['secrets']['production_db_key_base'] = 'production' # UPDATE THIS, at least 30 chars. Used to encrypt Variables.

# Gravatar
default['gitlab']['gravatar']['enabled'] = true

# Mysql
default['mysql']['server_root_password'] = 'Ch4ngm3'
default['build-essential']['compile_time'] = true # needed for mysql chef_gem

# nginx
default['nginx']['default_site_enabled'] = false

# Gitlab git http server
default['gitlab']['git_http_server_revision'] = 'master'
default['gitlab']['git_http_server_repository'] = 'https://gitlab.com/gitlab-org/gitlab-git-http-server.git'
