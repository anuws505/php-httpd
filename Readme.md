# Docker with PHP multiple sites

## Step to reproduce
1. Clone this repository
2. Edit your .env
3. Edit docker-compose.yml follow the .env file and complete custom virtual host
4. Edit `config/000-default.conf` follow docker-compose.yml (correct ServerName and DocumentRoot)
5. Edit host file on your local, add the virtual domain
(Mac: /private/etc/hosts, Windows: C:/Windows/System32/Drivers/etc/hosts)
```
127.0.0.1       test1.test
127.0.0.1       test2.test
```
6. Run `docker-compose build` and `docker-compose up -d`
7. Try to access the domain with port via your browser (for example: http://test.test, http://test2.test)
```
> curl test1.test:8006
result => "this is test1 site"
> curl test2.test:8007
result => "this is test2 site"
```
## Step to manual build image
1. Build docker image with tag name
```
docker builder prune --all
docker build -t php-httpd:v1.0 . --no-cache
```
2. Docker run or run with map path
```
docker run -d --name php-httpd-run -p 80:80 php-httpd:v1.0
```
or
```
docker run -d --name php-httpd-run \
-v certs:/opt/certs \
-v www:/var/www/html \
-p 80:80 php-httpd:v1.0
```
3. Access php-httpd-run
```
docker exec -it php-httpd-run /bin/bash
```
## Hidden command for helper
```
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;

curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

docker run -d --name mysql-app-run \
-v /Users/name/php-httpd/mysql:/var/lib/mysql \
-e MYSQL_ROOT_PASSWORD=password \
-e MYSQL_DATABASE=dbname \
-e MYSQL_USER=dbuser \
-e MYSQL_PASSWORD=dbpassword \
-p 3306:3306 mysql:8

docker exec -it mysql-app-run /bin/bash
```
