maintainer 'Eric G. Wolfe'
maintainer_email 'eric.wolfe@gmail.com'
license 'Apache 2.0'
description 'Installs/Configures gitlab'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
name 'gitlab'
version '8.0.2'
issues_url 'https://github.com/atomic-penguin/cookbook-gitlab/issues'
source_url 'https://github.com/atomic-penguin/cookbook-gitlab'

%w(build-essential zlib readline ncurses git openssh redisio xml
   ruby_build certificate database logrotate
   postgresql apt yum-epel selinux_policy).each do |cb_depend|
  depends cb_depend
end
depends 'mysql', '~> 6.0'
depends 'mysql2_chef_gem'
depends 'nginx', '<3'

%w(redhat centos scientific amazon debian ubuntu).each do |os|
  supports os
end
