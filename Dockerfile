FROM ubuntu:20.04

MAINTAINER <JMD> contatc@juniormesquitadandao.com

SHELL ["/bin/bash", "-l", "-c"]

ARG RUBY_VERSION
ARG RAILS_VERSION
ARG NODE_VERSION
ARG YARN_VERSION
RUN [[ -z "$RUBY_VERSION" ]] && { echo "Arg RUBY_VERSION can't be blank."; exit 1; } || { echo "RUBY_VERSION: $RUBY_VERSION"; };
RUN [[ -z "$RAILS_VERSION" ]] && { echo "Arg RAILS_VERSION can't be blank."; exit 1; } || { echo "RAILS_VERSION: $RAILS_VERSION"; };
RUN [[ -z "$NODE_VERSION" ]] && { echo "Arg NODE_VERSION can't be blank."; exit 1; } || { echo "NODE_VERSION: $NODE_VERSION"; };
RUN [[ -z "$YARN_VERSION" ]] && { echo "Arg YARN_VERSION can't be blank."; exit 1; } || { echo "YARN_VERSION: $YARN_VERSION"; };

# stat -c "%a %n" *
# chmod 664 -R .
# chmod 775 $(find . -type d)
RUN chmod 775 /home

RUN apt update && \
  apt upgrade -y && \
  apt install -y software-properties-common curl gnupg2

# RVM <https://rvm.io/rvm/install>
RUN gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB && \
  curl -sSL https://get.rvm.io | bash -s stable && \
  echo 'source /etc/profile.d/rvm.sh' >> ~/.bashrc && \
  echo 'rvm_silence_path_mismatch_check_flag=1' >> ~/.rvmrc && \
  source /etc/profile.d/rvm.sh && \
  rvm rvmrc warning ignore allGemfiles && \
  rvm install $RUBY_VERSION && \
  rvm --default use $RUBY_VERSION && \
  gem install rails --version=$RAILS_VERSION -N && \
  gem install bundler --conservative -N

# NVM <https://github.com/nvm-sh/nvm>
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.1/install.sh | bash && \
  export NVM_DIR="$HOME/.nvm" && \
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" && \
  nvm install $NODE_VERSION && \
  nvm use $NODE_VERSION && \
  npm install yarn@$YARN_VERSION -g

ARG AROUND_BUILD
RUN /bin/bash -l -c "$AROUND_BUILD"

RUN apt update && apt upgrade -y

RUN lsb_release -a && \
  source /etc/profile.d/rvm.sh && \
  rvm -v && \
  ruby -v && \
  rails -v && \
  bundler -v && \
  export NVM_DIR="$HOME/.nvm" && \
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" && \
  echo "nvm `nvm -v`" && \
  echo "npm `npm -v`" && \
  echo "node `node -v`" && \
  echo "yarn `yarn -v`"
