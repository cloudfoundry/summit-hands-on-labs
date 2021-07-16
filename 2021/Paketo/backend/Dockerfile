FROM ubuntu:bionic

ENV LANG="C.UTF-8"
ENV DEBIAN_FRONTEND noninteractive

# Install dependencies
RUN apt-get -qqy update \
  && apt-get -qqy install \
    gnupg \
    make \
    wget \
  && apt-get -qqy clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install ruby-install
ARG ruby_install_version=0.8.2
RUN wget https://raw.github.com/postmodern/postmodern.github.io/master/postmodern.asc \
  && gpg --import postmodern.asc \
  && wget -O "ruby-install-${ruby_install_version}.tar.gz" "https://github.com/postmodern/ruby-install/archive/v${ruby_install_version}.tar.gz" \
  && wget "https://raw.github.com/postmodern/ruby-install/master/pkg/ruby-install-${ruby_install_version}.tar.gz.asc" \
  && gpg --verify "ruby-install-${ruby_install_version}.tar.gz.asc" "ruby-install-${ruby_install_version}.tar.gz" \
  && tar -xzvf "ruby-install-${ruby_install_version}.tar.gz" \
  && cd "ruby-install-${ruby_install_version}/" \
  && make install \
  && cd - \
  && rm -rf "ruby-install-${ruby_install_version}/" \
  && rm "ruby-install-${ruby_install_version}.tar.gz"

# Install ruby
ARG ruby_version=3.0.2
RUN apt-get -qqy update \
  && ruby-install ruby "${ruby_version}" \
  && ln -s "/opt/rubies/$(ls /opt/rubies | head -1)" /opt/rubies/latest \
  && apt-get -qqy clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV GEM_HOME "${HOME}/.gem"
ENV GEM_PATH "${HOME}/.gem"
ENV PATH "/opt/rubies/latest/bin:${GEM_PATH}/bin:${PATH}"

# Install gems
WORKDIR /tmp
RUN echo 'gem: --no-rdoc --no-ri' >> "$HOME/.gemrc"
COPY Gemfile /tmp
COPY Gemfile.lock /tmp
RUN bundle install

# Setup user, home, and app
RUN useradd -ms /bin/bash vcap
WORKDIR /home/vcap/app
COPY . /home/vcap/app
RUN chown -R vcap:vcap /home/vcap
USER vcap:vcap

ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_ENV production
EXPOSE 3000
ENTRYPOINT [ "rails", "server" ]
