maintainer 'Eric G. Wolfe'
maintainer_email 'eric.wolfe@gmail.com'
license 'Apache 2.0'
description 'Installs/Configures gitlab'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
name 'gitlab'
version '10.1.0'
issues_url 'https://github.com/atomic-penguin/cookbook-gitlab/issues'
source_url 'https://github.com/atomic-penguin/cookbook-gitlab'

%w(
  apt
  build-essential
  certificate
  chef_nginx
  database
  git
  logrotate
  ncurses
  nodejs
  openssh
  postgresql
  readline
  redisio
  ruby_build
  selinux_policy
  xml
  yarn
  yum-epel
  zlib
).each do |cb_depend|
  depends cb_depend
end
depends 'mysql', '~> 6.0'
depends 'mysql2_chef_gem', '~> 1.0'

%w(redhat centos scientific amazon debian ubuntu).each do |os|
  supports os
end
