FROM ubuntu
RUN apt-get update 
RUN apt-get update -q && apt-get install -qy curl
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN \curl -L https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install 2.3.4"
RUN /bin/bash -l -c "rvm use 2.3.4 --default"
RUN apt-get install rubygems -y
RUN apt-get update -q && apt-get install build-essential patch ruby-dev zlib1g-dev liblzma-dev -y