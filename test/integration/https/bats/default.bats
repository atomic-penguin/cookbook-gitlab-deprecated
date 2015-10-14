#!/usr/bin/env bats

@test 'unicorn rails is listening on gitlab.socket' {
  test -S /srv/git/gitlab/tmp/sockets/gitlab.socket
}

@test 'redis-server is running' {
  pgrep redis-server
}


@test 'mysql schema is initialized and has projects* tables' {
  for PREFIX in '/var/lib' '/var/run'; do
    test -z $SOCK || break
    for INSTANCE in 'mysql' 'mysql-default'; do
      test -z $SOCK || break
      for SOCKNAME in 'mysql' 'mysqld'; do
        SOCK=$PREFIX/$INSTANCE/$SOCKNAME.sock
        test -e $SOCK && {
            export SOCK
            break
        }
        unset SOCK
      done
    done
  done
  echo 'show tables;' | mysql -S $SOCK -u root --password='test' gitlab | grep 'projects'
}

@test 'nginx is running' {
  pgrep nginx 
}

@test 'nginx is listening on :443' {
  netstat -lnp | grep ':443' | grep 'nginx'
}
