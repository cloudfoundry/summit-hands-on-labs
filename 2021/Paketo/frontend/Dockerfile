FROM ubuntu:bionic as builder

ENV LANG="C.UTF-8"
ENV DEBIAN_FRONTEND noninteractive

# Install dependencies
RUN apt-get -qqy update \
  && apt-get -qqy install \
    wget \
    xz-utils \
  && apt-get -qqy clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Node.js
ARG node_version=14.17.3
RUN wget "https://nodejs.org/dist/v${node_version}/node-v${node_version}-linux-x64.tar.xz" \
  && mkdir -p /usr/local/lib/nodejs \
  && tar -xJvf "node-v${node_version}-linux-x64.tar.xz" -C /usr/local/lib/nodejs \
  && rm "node-v${node_version}-linux-x64.tar.xz"

ENV PATH "/usr/local/lib/nodejs/node-v${node_version}-linux-x64/bin:${PATH}"

# Install yarn
RUN npm install --global yarn

# Build app
COPY . /tmp/app
WORKDIR /tmp/app
RUN yarn install && yarn run build

FROM ubuntu:bionic as final

# Install dependencies
RUN apt-get -qqy update \
  && apt-get -qqy install \
    build-essential \
    gettext-base \
    libpcre3-dev \
    make \
    wget \
    zlib1g-dev \
  && apt-get -qqy clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install NGINX
ARG nginx_version=1.20.1
RUN wget "https://nginx.org/download/nginx-${nginx_version}.tar.gz" \
  && tar -xzvf "nginx-${nginx_version}.tar.gz" \
  && cd "nginx-${nginx_version}" \
  && ./configure --with-http_sub_module \
  && make && make install \
  && cd - \
  && rm "nginx-${nginx_version}.tar.gz" \
  && rm -rf "nginx-${nginx_version}" \
  && chmod a+rwx -R /usr/local/nginx

ENV PATH "/usr/local/nginx/sbin:${PATH}"

# Setup user, home, and app
RUN useradd -ms /bin/bash vcap
WORKDIR /workspace
COPY --from=builder /tmp/app/build /workspace/build
COPY --from=builder /tmp/app/nginx.conf /workspace/nginx.conf
COPY --from=builder /tmp/app/mime.types /workspace/mime.types
COPY --from=builder /tmp/app/run.sh /workspace/run.sh
RUN chown -R vcap:vcap /workspace

USER vcap:vcap
EXPOSE 3000
ENTRYPOINT [ "/workspace/run.sh" ]
