maintainer       "Gerald L. Hevener Jr., M.S."
maintainer_email "hevenerg@marshall.edu"
license          "Apache 2.0"
description      "Installs/Configures gitlab"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.2.1"
%w{ gitolite nginx }.each do |cb_conflict|
  conflicts cb_conflict
end
%w{ ruby_build chef_gem git sqlite redisio build-essential python readline sudo openssh perl xml zlib}.each do |cb_depend|
  depends cb_depend
end
%w{ redhat centos scientific amazon debian ubuntu }.each do |os|
  supports os
end
