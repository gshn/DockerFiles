### 
### LEMP STACK
###
### docker build --force-rm=true -t gshn/lemp-stack .
### docker run -p 80:80 -d gshn/lemp-stack /bin/bash

FROM gshn/ubuntu:16.04

ENV DOMAIN domain.com
ENV DBROOTPASS dbrootpass
ENV PHPVERSION 7.2
ENV PHPMYADMIN_VERSION 4.8.0.1
ENV PHPMYADMIN_DIRECTORY phpMyAdmin
ENV USERID userid
ENV USERPW userpw
ENV DOCUMENT_ROOT /home/${USERID}/app/public
ENV EMAIL userid@domain.com
ENV RUNLEVEL 1

## Avoid ERROR: invoke-rc.d: policy-rc.d denied execution of start.
RUN sed -i "s/^exit 101$/exit 0/" /usr/sbin/policy-rc.d

## apt-key 추가
RUN apt-get -y install software-properties-common && \
    echo "deb http://nginx.org/packages/mainline/ubuntu/ xenial nginx" >> /etc/apt/sources.list && \
    echo "deb-src http://nginx.org/packages/mainline/ubuntu/ xenial nginx" >> /etc/apt/sources.list && \
    echo "deb-src http://sgp1.mirrors.digitalocean.com/mariadb/repo/10.2/ubuntu xenial main" >> /etc/apt/sources.list && \
    wget http://nginx.org/keys/nginx_signing.key && \
    apt-key add nginx_signing.key && \
    rm nginx_signing.key && \
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8 && \
    LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php && \
    apt-get update

## nginx 설치
RUN apt-get -y install nginx

## php 설치
RUN apt-get -y install php$PHPVERSION-fpm php$PHPVERSION-intl php$PHPVERSION-gd php$PHPVERSION-curl php$PHPVERSION-mbstring php$PHPVERSION-xml php$PHPVERSION-zip && \
    sed -i 's/;emergency_restart_threshold = 0/emergency_restart_threshold = 10/' /etc/php/$PHPVERSION/fpm/php-fpm.conf && \
    sed -i 's/;emergency_restart_interval = 0/emergency_restart_interval = 1m/' /etc/php/$PHPVERSION/fpm/php-fpm.conf

## mariaDB 설치
RUN echo mariadb-server mysql-server/root_password password $DBROOTPASS | debconf-set-selections && \
    echo mariadb-server mysql-server/root_password_again password $DBROOTPASS | debconf-set-selections && \
    apt-get -y install mariadb-server mariadb-client && \
    apt-get -y install php$PHPVERSION-mysql

## mariaDB 설정
RUN echo "[client]\
    default-character-set=utf8mb4\
    [mysql]\
    default-character-set=utf8mb4\
    [mysqld]\
    collation-server = utf8mb4_unicode_ci\
    character_set_server = utf8mb4\
    init-connect='SET NAMES utf8mb4'\
    lower_case_table_names=1\
    query_cache_type = 1\
    query_cache_min_res_unit = 2k\
    sql_mode = NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION\
    max_allowed_packet = 32M\
    slow_query_log = 1\
    long_query_time = 2\
    [mysqldump]\
    default-character-set=utf8mb4\
    max_allowed_packet = 32M\
    " > /etc/mysql/conf.d/mariadb.cnf

## memcached 캐시서버 설치
RUN apt-get -y install memcached && \
    apt-get -y install php$PHPVERSION-memcached

## nginx 기본 설정 변경
RUN echo "fastcgi_param   QUERY_STRING            \$query_string;\
    fastcgi_param   REQUEST_METHOD          \$request_method;\
    fastcgi_param   CONTENT_TYPE            \$content_type;\
    fastcgi_param   CONTENT_LENGTH          \$content_length;\
    fastcgi_param   SCRIPT_FILENAME         \$document_root\$fastcgi_script_name;\
    fastcgi_param   SCRIPT_NAME             \$fastcgi_script_name;\
    fastcgi_param   PATH_INFO               \$fastcgi_path_info;\
    fastcgi_param   PATH_TRANSLATED         \$document_root\$fastcgi_path_info;\
    fastcgi_param   REQUEST_URI             \$request_uri;\
    fastcgi_param   DOCUMENT_URI            \$document_uri;\
    fastcgi_param   DOCUMENT_ROOT           \$document_root;\
    fastcgi_param   SERVER_PROTOCOL         \$server_protocol;\
    fastcgi_param   GATEWAY_INTERFACE       CGI/1.1;\
    fastcgi_param   SERVER_SOFTWARE         nginx/\$nginx_version;\
    fastcgi_param   REMOTE_ADDR             \$remote_addr;\
    fastcgi_param   REMOTE_PORT             \$remote_port;\
    fastcgi_param   SERVER_ADDR             \$server_addr;\
    fastcgi_param   SERVER_PORT             \$server_port;\
    fastcgi_param   SERVER_NAME             \$server_name;\
    fastcgi_param   HTTPS                   \$https;\
    # PHP only, required if PHP was built with --enable-force-cgi-redirect\
    fastcgi_param   REDIRECT_STATUS         200;\
    " > /etc/nginx/fastcgi_params && \
    echo "user  www-data;\
    worker_processes auto;\
    worker_rlimit_nofile 100000;\
    pid        /var/run/nginx.pid;\
    error_log  /var/log/nginx/error.log error;\
    events {\
        worker_connections  4096;\
        use epoll;\
        multi_accept on;\
    }\
    http {\
        server_tokens off;\
        add_header X-Frame-Options SAMEORIGIN;\
        add_header X-Content-Type-Options nosniff;\
        add_header X-XSS-Protection '1;mode=block';\
        include       /etc/nginx/mime.types;\
        default_type  application/octet-stream;\
        access_log off;\
        client_body_buffer_size     16k;\
        client_header_buffer_size   1k;\
        client_max_body_size        0;\
        large_client_header_buffers 2 1k;\
        client_body_timeout     12;\
        client_header_timeout   12;\
        keepalive_timeout       15;\
        send_timeout            10;\
        gzip                    on;\
        gzip_comp_level         2;\
        gzip_min_length         1000;\
        gzip_proxied            expired no-cache no-store private auth;\
        gzip_types              text/plain text/css text/x-component\
                                text/xml application/xml application/xhtml+xml application/json\
                                image/x-icon image/bmp image/svg+xml application/atom+xml\
                                text/javascript application/javascript application/x-javascript\
                                application/pdf application/postscript\
                                application/rtf application/msword\
                                application/vnd.ms-powerpoint application/vnd.ms-excel\
                                application/vnd.ms-fontobject application/vnd.wap.wml\
                                application/x-font-ttf application/x-font-opentype;\
        include /etc/nginx/conf.d/*.conf;\
    }\
    " > /etc/nginx/nginx.conf && \
    echo "server {\
        listen 80 default_server;\
        server_name localhost;\
        root /usr/share/nginx/html;\
        location / {\
            index  index.php index.html;\
        }\
        location ~ [^/]\.php(/|$) {\
            fastcgi_split_path_info ^(.+?\.php)(/.*)$;\
            if (!-f \$document_root\$fastcgi_script_name) {\
                return 404;\
            }\
            fastcgi_pass unix:/run/php/php${PHPVERSION}-fpm.sock;\
            fastcgi_index index.php;\
            fastcgi_buffers 64 16k;\
            include fastcgi_params;\
        }\
    }\
    " > /etc/nginx/conf.d/default.conf

## phpmyadmin 설치
RUN cd /usr/share/nginx/html && \
    wget https://files.phpmyadmin.net/phpMyAdmin/$PHPMYADMIN_VERSION/phpMyAdmin-$PHPMYADMIN_VERSION-all-languages.zip && \
    unzip phpMyAdmin-$PHPMYADMIN_VERSION-all-languages.zip && \
    mv phpMyAdmin-$PHPMYADMIN_VERSION-all-languages $PHPMYADMIN_DIRECTORY && \
    rm phpMyAdmin-$PHPMYADMIN_VERSION-all-languages.zip && \
    mv $PHPMYADMIN_DIRECTORY/config.sample.inc.php $PHPMYADMIN_DIRECTORY/config.inc.php && \
    BLOWFISH="$(tr -dc 'a-zA-Z0-9~\!@#$%^&*_()+}{?></;.,[]=-' < /dev/urandom | fold -w 32 | head -n 1)" && \
    sed -i "s/''/'${BLOWFISH}'/" $PHPMYADMIN_DIRECTORY/config.inc.php && \
    cd ~

##' 사용자 추가 
RUN adduser --disabled-password --gecos "" $USERID && \
    echo "${USERID}:${USERPW}" | chpasswd && \
    su -c "mkdir -p ${DOCUMENT_ROOT}" $USERID && \
    su -c 'mkdir ~/log' $USERID && \
    su -c "echo 'success' > ${DOCUMENT_ROOT}/index.php" $USERID

## 사용자 php 설정
RUN echo "[${USERID}]\
    user = ${USERID}\
    group = ${USERID}\
    listen = /run/php/${USERID}.sock\
    listen.owner = ${USERID}\
    listen.group = www-data\
    pm = dynamic\
    pm.max_children = 9\
    pm.start_servers = 3\
    pm.min_spare_servers = 2\
    pm.max_spare_servers = 4\
    pm.max_requests = 200\
    php_admin_value[date.timezone] = Asia/Seoul\
    php_admin_value[opcache.memory_consumption] = 128\
    php_admin_value[opcache.interned_strings_buffer] = 16\
    php_admin_value[opcache.max_accelerated_files] = 10000\
    php_admin_value[opcache.validate_timestamps] = 1\
    php_admin_value[opcache.revalidate_freq] = 0 ;0:개발, 1:라이브수정, 2:최적성능\
    php_admin_value[opcache.fast_shutdown] = 1\
    php_admin_value[max_execution_time] = 60\
    php_admin_value[max_input_time] = 60\
    php_admin_value[post_max_size] = 30M\
    php_admin_value[upload_max_filesize] = 20M\
    php_admin_value[upload_tmp_dir]=/home/${USERID}/upload_tmp\
    php_admin_value[session.save_handler] = 'memcached'\
    php_admin_value[session.save_path] = '127.0.0.1:11211'\
    php_admin_value[realpath_cache_size] = 64k\
    php_admin_value[short_open_tag] = On\
    " > /etc/php/$PHPVERSION/fpm/pool.d/$USERID.conf

## 사용자 nginx 설정
RUN echo "server {\
        listen      80;\
        server_name ${DOMAIN};\
        root        ${DOCUMENT_ROOT};\
        access_log /home/${USERID}/log/access.log;\
        error_log  /home/${USERID}/log/error.log warn;\
        location / {\
            index  index.php index.html;\
            try_files \$uri \$uri/ /index.php?\$args;\
        }\
        location ^~ /.well-known/acme-challenge/ {\
            allow all;\
        }\
        location ~ /\. {\
            deny all;\
        }\
        location ~* \.(log|binary|pem|enc|crt|conf|cnf|sql|sh|key)$ {\
            deny all;\
        }\
        location ~* (composer\.json|contributing\.md|license\.txt|readme\.rst|readme\.md|readme\.txt|copyright|artisan|gulpfile\.js|package\.json|phpunit\.xml)$ {\
            deny all;\
        }\
        location = /favicon.ico {\
            log_not_found off;\
            access_log off;\
        }\
        location = /robots.txt {\
            log_not_found off;\
            access_log off;\
        }\
        location ~ [^/]\.(css|js|gif|png|jpg|jpeg|eot|svg|ttf|woff|woff2|otf)(/|$) {\
            access_log off;\
            add_header Cache-Control must-revalidate;\
            expires 1y;\
            etag on;\
        }\
        location ~* /(?:uploads|files|data)/.*\.php$ {\
            deny all;\
        }\
        location ~ [^/]\.php(/|$) {\
            fastcgi_split_path_info ^(.+?\.php)(/.*)$;\
            if (!-f \$document_root\$fastcgi_script_name) {\
                return 404;\
            }\
            fastcgi_pass unix:/run/php/${USERID}.sock;\
            fastcgi_index index.php;\
            fastcgi_buffers 64 16k;\
            include fastcgi_params;\
        }\
    }\
    " > /etc/nginx/conf.d/$USERID.conf

# Clean file
RUN	apt-get autoclean

COPY ./docker-entrypoint.sh /
RUN	chmod +x /docker-entrypoint.sh

## PORTS
EXPOSE 80 443 3306 11211

ENTRYPOINT ["/docker-entrypoint.sh"]