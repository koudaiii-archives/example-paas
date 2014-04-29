require 'rake'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/*/*_spec.rb'
end

task :default => :spec

namespace :docker do
  task :build do
      sh("docker build -t base ./docker-app-base")
      sh("docker build -t base .")
  end
  task :create do
    puts 'create git repository'
    sh('bundle exec ruby ./create-repos.rb')
  end
  
  task :clean do
    puts '---> Removing all containers...'
    sh('docker rm $(docker ps -a -q) || :')
    puts '---> Removing all <none> images...'
    sh("docker rmi $(docker images | grep -e '^<none>' | awk '{ print $3 }' ) || :")
  end
end
