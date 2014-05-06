# FROM ENV['DOCKER_USER']/ENV['DOCKER_TAG'] 
FROM koudaiii/example-paas

MAINTAINER koudaiiii "cs006061@gmail.com"


RUN apt-get update
RUN apt-get install -y git
RUN apt-get clean

RUN mkdir -p /root/.ssh; chmod 700 /root/.ssh
RUN echo "Host *\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config
ADD ./authorized_keys /root/.ssh/id_rsa
RUN chmod 700 /root/.ssh/id_rsa

#RUN ssh-keygen -t rsa
#RUN cat /root/.ssh/id_rsa.pub >> /home/koud/.ssh/authorized_keys

## install buildpacks
RUN mkdir /var/lib/buildpacks
RUN cd /var/lib/buildpacks && git clone https://github.com/heroku/heroku-buildpack-ruby

ADD ./exec-release.rb /var/lib/buildpacks/exec-release.rb
RUN chmod 755 /var/lib/buildpacks/exec-release.rb
