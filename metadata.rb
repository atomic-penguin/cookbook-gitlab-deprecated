maintainer       "Gerald L. Hevener"
maintainer_email "hevenerg@marshall.edu"
license          "Apache 2.0"
description      "Installs/Configures gitlab"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"
conflicts        "gitolite"
%w{ chef_gem git sqlite redisio build-essential python readline sudo openssh perl xml zlib}.each do |cb|
  depends cb
end
%w{ redhat centos scientific amazon debin ubuntu linuxmint }.each do |os|
  supports os
end
