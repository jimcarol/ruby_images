FROM daocloud.io/ubuntu:14.04
RUN apt-get update 
RUN apt-get update -q && apt-get install -qy curl
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN \curl -L https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "source /etc/profile.d/rvm.sh"
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install 2.3.4"
RUN /bin/bash -l -c "rvm use 2.3.4 --default"
RUN /bin/bash -l -c "gem install bundler"

WORKDIR /app
ADD /lib /app
RUN /bin/bash -l -c "bundle install"
CMD ["/bin/bash"]
EXPOSE 3006