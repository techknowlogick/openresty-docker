FROM alpine:3.4

RUN \
  apk update && \
  apk add \
   --virtual build-deps \
   make gcc musl-dev \
   pcre-dev openssl-dev zlib-dev ncurses-dev readline-dev \
   curl perl && \
   #libmaxminddb libmaxminddb-dev && \
  curl -sL https://github.com/leev/ngx_http_geoip2_module/archive/1.1.tar.gz | tar zxf - && \
  curl -sL https://openresty.org/download/openresty-1.11.2.1.tar.gz | tar zxf - && \
  cd openresty-* && \
  ./configure \
    --with-luajit --with-pcre-jit \
    --with-http_realip_module --with-ipv6 && \
    #--add-module=../ngx_http_geoip2_module*/ && \
  make && \
  make install && \
  make clean && \
  cd .. && \
  rm -rf openresty-* && \
  rm -rf ngx_http_geoip2_module-* && \
  sed -i 's/mime.types/\/usr\/local\/openresty\/nginx\/conf\/mime.types/g' /usr/local/openresty/nginx/conf/nginx.conf && \
  sed -i 's/#access_log/access_log \/dev\/stdout;#/g' /usr/local/openresty/nginx/conf/nginx.conf && \
  cp -pR '/usr/local/openresty/nginx/conf/.' '/etc/nginx/' && \
  echo "daemon off;error_log /dev/stdout;" >> "/etc/nginx/nginx.conf" && \
  ln -s /usr/local/openresty/nginx/sbin/nginx /usr/local/bin/nginx && \
  curl -sL https://github.com/p0pr0ck5/lua-resty-waf/archive/v0.8.tar.gz | tar zxf - && \
  cd lua-resty-waf-0.8 && \
  echo 'SHELL = /bin/ash' >> Makefile && \
  make install-hard && \
  apk del build-deps && \
  apk add \
    libpcrecpp libpcre16 libpcre32 openssl libssl1.0 pcre libgcc libstdc++ && \
  rm -rf /var/cache/apk/*

# Define the default command.
CMD ["nginx", "-c", "/etc/nginx/nginx.conf"]
