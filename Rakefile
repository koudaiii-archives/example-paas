require 'rake'
require 'rspec/core/rake_task'
require 'dotenv/tasks'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/*/*_spec.rb'
end

task :default => :spec

namespace :docker do
  desc "build"
  task :build => :dotenv do
  docker_user = ENV['DOCKER_USER']
  docker_tag = ENV['DOCKER_TAG']
      sh("docker build -t #{docker_user}/#{docker_tag} ./docker-app-base")
#      sh("docker commit #{docker_user}/#{docker_tag}")
#      sh("docker push #{docker_user}/#{docker_tag}")
      sh("docker build -t #{docker_user}/#{docker_tag} .")
  end
  desc "create repository"
  task :create do
    puts 'create git repository'
    sh('bundle exec ruby ./create-repos.rb')
  end
  desc "docker clean,not clean repository"
  task :clean do
    puts '---> Removing all containers...'
    sh('docker rm $(docker ps -a -q) || :')
    puts '---> Removing all <none> images...'
    sh("docker rmi $(docker images | grep -e '^<none>' | awk '{ print $3 }' ) || :")
  end
end
