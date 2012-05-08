maintainer       "Gerald L. Hevener"
maintainer_email "hevenerg@marshall.edu"
license          "Apache 2.0"
description      "Installs/Configures gitlab"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.18"
%w{ git gitolite sqlite redisio::install redisio::enable build-essential readline sudo openssh xml zlib}.each do |cb|
  depends cb
end
%w{ redhat centos scientific amazon debin ubuntu linuxmint }.each do |os|
  supports os
end
