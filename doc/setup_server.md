
Setting up a server
===================

This document describes setting up a deployment environment on a Linux server with RVM, MySQL, and Nginx.


As root
-------

Install required packages:

    apt-get install mysql-client mysql-server ruby-dev libsqlite3-dev libmysqlclient-dev nginx mercurial build-essential java6-sdk git-core libreadline6-dev libssl-dev libpq-dev

Create the `cmsprod` user:

    adduser --shell /bin/bash --disabled-password --home /home1/cmsprod cmsprod

Become the `cmsprod` user:

    su - cmsprod


As cmsprod
----------

Install RVM by following instructions at http://beginrescueend.com/ .

Run:

    rvm install jruby # or ruby-1.9.3
    rvm gemset create cms

Add to .bashrc

    alias so='. ~/.bashrc ; . ~/.profile'
    alias my='mysql -ucmsprod -pcmsprod cms'
    alias mydump='mysqldump -ucmsprod -pcmsprod cms'
    export RAILS_ENV=production
    export JRUBY_OPTS=--1.9

Set `RAILS_ENV` to 'development' if this is not production.

Setup rubygems:

    hg clone https://rails.compliance-management.googlecode.com/hg/ cms
    cd cms

At this point rvm will ask you if it should trust the .rvmrc in this project directory.  Say yes and the correct version .

    gem update --system
    gem install bundler
    bundle install --binstubs
    mkdir log

    sudo mysql

At the `mysql>` prompt:

    create database cms;
    grant all on cms.* to cms@localhost identified by "cms";

Adjust `config/database.yml` to match your database settings.


For dev
=======

  rake db:automigrate seed
  rake db:sessions:create
  my
      alter table sessions modify sessions longtext;
  script/rails server

For prod
========

Change /etc/nginx/sites-enabled/default:

    server {
            listen   80 default;
            server_name  SERVER;

            access_log  /var/log/nginx/cms-access.log;

            location / {
                    proxy_pass http://localhost:3000/;

                    proxy_set_header  X-Real-IP  $remote_addr;
                    proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_set_header  Host $http_host;

                    root   /var/www/nginx-default;
                    index  index.html index.htm;
            }
    }

Adjust `SERVER` above to your hostname as visible from outside.

And finally, starting the application server in production:

    script/rails server -d

