

## 1. Install dependencies
````
sudo apt install nginx mysql-server php-fpm php-mysql php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc php-zip
````

option B
````
sudo apt update
````
````
sudo apt install nginx mariadb-server php-fpm php-mysql php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc php-zip -y
````

````
sudo mysql -u root -p
````

````
CREATE DATABASE wordpress_db;
CREATE USER 'wp_user'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON wordpress_db.* TO 'wp_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
````

````
cd /tmp
curl -LO https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
````

````
sudo mkdir -p /var/www/mon-site.com
sudo cp -a /tmp/wordpress/. /var/www/mon-site.com
sudo chown -R www-data:www-data /var/www/mon-site.com
sudo chmod -R 755 /var/www/mon-site.com
````
