FROM alpine:3.3

RUN \
  apk update && \
  apk add \
   --virtual build-deps \
   make gcc musl-dev \
   pcre-dev openssl-dev zlib-dev ncurses-dev readline-dev \
   curl perl && \
  curl -sL https://github.com/nbs-system/naxsi/archive/0.54.tar.gz | tar zxf - && \
  curl -sL https://openresty.org/download/openresty-1.9.7.4.tar.gz | tar zxf - && \
  cd openresty-* && \
  ./configure --add-module=../naxsi-*/naxsi_src/ --with-pcre-jit --with-ipv6 && \
  make && \
  make install && \
  make clean && \
  cd .. && \
  rm -rf openresty-* && \
  rm -rf naxsi-* && \
  ln -s /usr/local/openresty/nginx/sbin/nginx /usr/local/bin/nginx

# Define the default command.
CMD ["nginx", "-g", "daemon off; error_log /dev/stderr info; access_log /dev/stdout;"]
