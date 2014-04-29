#!/bin/bash
export PATH="/usr/local/bin:$PATH"
apt-get clean
apt-get update

apt-get -y install aptitude

apt-get -y --purge libssl1.0.0
apt-get -y --purge openssl

apt-get -y install openssl
apt-get -y install libssl1.0.0
apt-get -y install libssl-dev
apt-get -y install zlib1g-dev

apt-get -y install git-core curl
apt-get -y install libreadline-dev
apt-get -y install build-essential

#aptitude install -y libssl-dev

apt-get -y install libreadline-dev
apt-get -y install imagemagick

#for rubygems mysql2
apt-get install libmysqlclient-dev

#for capistrano zip
apt-get -y install bzip2*
apt-get -y install zlib-devel

# for nokogiri
apt-get -y install libxslt-dev
apt-get -y install libxml2-dev

# for Capybara-webkit
apt-get -y install libqtwebkit-dev


if [ ! -d /usr/local/rbenv ];then
    cd /usr/local
    git clone git://github.com/sstephenson/rbenv.git rbenv
    mkdir rbenv/shims rbenv/versions rbenv/plugins
    git clone git://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build

    # Setup rbenv for all user
    echo 'export RBENV_ROOT="/usr/local/rbenv"' >> /etc/profile.d/rbenv.sh
    echo 'export PATH=/usr/local/rbenv/bin:$PATH' >> /etc/profile.d/rbenv.sh
    echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh

    export RBENV_ROOT=/usr/local/rbenv
    export PATH=/usr/local/rbenv/bin:$PATH
    eval "$(rbenv init -)"

    # Install ruby
    rbenv install 2.1.1
    rbenv rehash
    rbenv global 2.1.1  # default ruby version

    #rbenv(add user to rbenv group if you want to use rbenv)
    useradd rbenv
    chown -R rbenv:rbenv rbenv
    chmod -R 775 rbenv

    # install withou ri,rdoc
    echo 'install: --no-ri --no-rdoc' >> /etc/.gemrc
    echo 'update: --no-ri --no-rdoc' >> /etc/.gemrc
    echo 'install: --no-ri --no-rdoc' >> /.gemrc
    echo 'update: --no-ri --no-rdoc' >> /.gemrc

    # install bundler
    gem install bundler
    gem install rehash
fi
