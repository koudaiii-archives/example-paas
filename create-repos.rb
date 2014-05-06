#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require "git"
require "erb"
require 'dotenv'

class Repository
  attr_accessor :git
  attr_reader :git_repo, :vm_addr, :basedir, :docker_user, :docker_tag

  def self.create(args)
    repo = self.new(args)
    repo.git = Git.init(repo.basedir + "/" + repo.reponame)
    repo.git.config('receive.denyCurrentBranch', 'ignore')

    Dir.chdir(repo.git.repo.path + "/hooks") do
      erb = ERB.new(DATA.read)
      File.open('post-update', 'w') do |f|
        f.puts(erb.result(repo.create_binding))
        f.chmod(0755)
      end
    end

    return repo
  end

  def initialize(args)
    @git_repo    = args[:git_repo]
    @vm_addr     = args[:vm_addr]
    @basedir     = args[:basedir]
    @docker_user = args[:docker_user]
    @docker_tag = args[:docker_tag]
  end

  def create_binding
    binding
  end

  def serial
    @serial ||= `ls #{@basedir} | wc -l`
  end

  def reponame
    sprintf("#{@docker_tag}-%04d", serial)
  end

  def port
    sprintf("5%04d", serial)
  end

  def dir
    git.dir
  end

  def url
    "#{git.dir}"
  end
end

Dotenv.load

repo = Repository.create(
  git_repo: ENV['GIT_REPO'],
  vm_addr:  ENV['VM_ADDR'],
  basedir:  ENV['BASEDIR'],
  docker_user: ENV['DOCKER_USER'],
  docker_tag:  ENV['DOCKER_TAG'],
)
puts repo.url


__END__
#!/bin/bash
set -eo pipefail
# set -x

export DOCKER_HOST=tcp://127.0.0.1:4243
export PATH=/usr/local/bin:$PATH

if [ -f is_running ];then
  echo "-----> Killing current container"
  job=`cat is_running`
  docker kill $job
fi

echo "-----> Fetching application source"

job=$(docker run -i -a stdin <%= docker_user %>/<%= docker_tag %> /bin/bash -l -c \
    "git clone <%= git_repo %> /root/<%= reponame %>")
test $(docker wait $job) -eq 0
docker commit $job <%= docker_user %>/<%= docker_tag %> > /dev/null

echo "-----> Building new container ..."

job=$(docker run -i -a stdin <%= docker_user %>/<%= docker_tag %> /bin/bash -l -c \
    "/var/lib/buildpacks/heroku-buildpack-ruby/bin/detect /root/<%= reponame %> && CURL_TIMEOUT=360 /var/lib/buildpacks/heroku-buildpack-ruby/bin/compile /root/<%= reponame %> /var/cache/buildpacks && /var/lib/buildpacks/heroku-buildpack-ruby/bin/release /root/<%= reponame %> > /root/<%= reponame %>/.release")
test $(docker wait $job) -eq 0
docker commit $job <%= docker_user %>/<%= docker_tag %> > /dev/null

echo "-----> Starting Application"

job=$(docker run -i -t -d -p <%= port %>:8080 <%= docker_user %>/<%= docker_tag %> /bin/bash -l -c \
     "export HOME=/root/<%= reponame %> && /var/lib/buildpacks/exec-release.rb .release")

echo $job > is_running
echo "URL: http://<%= vm_addr %>:<%= port %>/"
echo "http://<%= vm_addr %>:<%= port %>/" | pbcopy
