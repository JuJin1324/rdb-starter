docker build --tag starter/rdb-mysql:1.0 .; \
docker run -d \
-p 3310:3306 \
--name starter-rdb-mysql \
starter/rdb-mysql:1.0
