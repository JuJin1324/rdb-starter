FROM mysql:8.0.31
LABEL maintainer="jujin1324@daum.net"
LABEL dockerhub="https://hub.docker.com/_/mysql"

ADD rdb-starter.cnf /etc/mysql/conf.d/
ENV MYSQL_ROOT_PASSWORD root
ENV MYSQL_DATABASE rdb_starter
ENV MYSQL_USER rdb
ENV MYSQL_PASSWORD starter
