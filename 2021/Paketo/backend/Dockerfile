FROM ubuntu:bionic

ENV LANG="C.UTF-8"
ENV DEBIAN_FRONTEND noninteractive

# Install dependencies
RUN apt-get -qqy update \
  && apt-get -qqy install \
    build-essential \
    libcurl4-openssl-dev \
    libffi-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    libyaml-dev \
    ruby-dev \
    software-properties-common \
    sqlite3 \
    wget \
    zlib1g-dev \
  && apt-get -qqy clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# # Install ruby
RUN wget -O ruby.tgz https://buildpacks.cloudfoundry.org/dependencies/ruby/ruby_3.0.2_linux_x64_cflinuxfs3_34708973.tgz \
  && mkdir -p /opt/rubies/latest \
  && tar xzvf ruby.tgz -C /opt/rubies/latest

# Setup user, home, and app
RUN useradd -ms /bin/bash rubyuser
WORKDIR /home/rubyuser/app
COPY . /home/rubyuser/app
RUN chown -R rubyuser:rubyuser /home/rubyuser
RUN chown -R rubyuser:rubyuser /opt/rubies
USER rubyuser:rubyuser

ENV GEM_HOME "/home/rubyuser/.gem"
ENV GEM_PATH "/home/rubyuser/.gem"
ENV PATH "/opt/rubies/latest/bin:${GEM_PATH}/bin:${PATH}"

# Install gems
RUN echo 'gem: --no-rdoc --no-ri' >> "/home/rubyuser/.gemrc"
RUN bundle install

ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_ENV production
EXPOSE 3000
ENTRYPOINT [ "rails", "server" ]
