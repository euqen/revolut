sudo docker run -d \
  --name mysql \
  -p 3306:3306 \
  -v /var/lib/mysql:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
  -e MYSQL_DATABASE=${MYSQL_DATABASE} \
  -e MYSQL_USER=${MYSQL_USER} \
  -e MYSQL_PASSWORD=${MYSQL_PASSWORD} \
  mysql:8.0.33