#
# Openresty docker image
#
# This docker contains openresty (nginx) compiled from source with useful optional modules installed.
#
# Based on http://github.com/tenstartups/openresty-docker
#

FROM debian:jessie

# Set environment.
ENV \
  DEBIAN_FRONTEND=noninteractive \
  TERM=xterm-color

# Install packages.
RUN apt-get update && apt-get -y install \
  build-essential \
  curl \
  libreadline-dev \
  libncurses5-dev \
  libpcre3-dev \
  libssl-dev \
  nano \
  perl \
  wget \
  apache2-threaded-dev \
  libxml2-dev

# Fetch and compile openresty and mod_security from source
RUN \
  wget https://www.modsecurity.org/tarball/2.9.1-rc1/modsecurity-2.9.1-RC1.tar.gz && \
  tar -zxvf modsecurity-*.tar.gz && \
  rm -f modsecurity-*.tar.gz && \
  cd modsecurity-* && \
  ./configure --enable-standalone-module --disable-mlogc && \
  make && \
  cd .. && \
  wget https://openresty.org/download/openresty-1.9.7.4.tar.gz && \
  tar -xzvf openresty-*.tar.gz && \
  rm -f openresty-*.tar.gz && \
  cd openresty-* && \
  ./configure --with-pcre-jit --with-ipv6 --add-module=../modsecurity-*/nginx/modsecurity && \
  make && \
  make install && \
  make clean && \
  cd .. && \
  rm -rf openresty-* && \
  cp modsecurity-*/modsecurity.conf-recommended /usr/local/openresty/nginx/conf/modsecurity.conf && \
  cp modsecurity-*/unicode.mapping /usr/local/openresty/nginx/conf/unicode.mapping && \
  rm -rf modsecurity-* && \
  ln -s /usr/local/openresty/nginx/sbin/nginx /usr/local/bin/nginx && \
  ldconfig

# Set the working directory.
WORKDIR /home/openresty

# Add files to the container.
ADD . /home/openresty

# Expose volumes.
VOLUME ["/etc/nginx"]

# Set the entrypoint script.
ENTRYPOINT ["./entrypoint"]

# Define the default command.
CMD ["nginx", "-c", "/etc/nginx/nginx.conf"]
