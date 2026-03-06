# Static Site Server

> ### Prerequires
> To build this project you need to :
>
> - Have a remote server installed locally or on a VPS
> - Install nginx in your remote server
> - Have full access to you remote server
> 
> And then you can follow the steps bellow

> In my case i used two virtual machine i have create from my virtual box, both are ubuntu server 24.04 LTS
> 
> The first is used as client and the other as server.

## 1. On your remote server
### 1.1. Make sure your machine can connect with another in the virtual box
> If it is not the case, add a network adapter as bridge or virtual host network
> 
> **List your network interfaces**
> ````
> ip a
>````
> **Or with nmcli if it is installed**
> ````
> nmcli device
> ````
> **If nmcli is not yet installed**
> ````
> sudo apt install network-manager
> ````
> **Then with nmcli add the connection**
> ````
> sudo nmcli con add type ethernet con-name "con-enp0s8" ifname "enp0s8"
> ````
> **'enp0s8'** is your network interface
> 
> **Up the connection**
> ````
> sudo nmcli con up "con-enp0s8"
> ````
> The connection could not go up on the machine reboot, you need to **force it to auto-connect on mavhine reboot**.
> ````
> sudo nmcli connection modify "con-enp0s8" connection.autoconnect yes
>````

### 1.2. Install OpenSSH Server
````
sudo apt update && sudo apt install openssh-server -y
````
> If you want to cofigure advanced setting of ssh remote server connection like the prive key connection, just navigate to the folder **ssh-remote-server-setup**, you will see all the steps to setting up avanced ssh configs.

### 1.3. Install nginx 
````
sudo apt update && sudo apt install nginx -y
````
> In my case i ran this project on a virtual host with custom port like 81

### 1.4 Navigate to nginx configs folder and create virtual host config
````
cd /etc/nginx/sites-available/
````

### 1.5 Create and edit the config file
````
sudo vim your_config_file.conf
````
And then paste this into the file
````
server {
        listen 81;
        listen [::]:81;

        root /var/www/html/s81/;

        index index.html;

        location / {
                try_files $uri $uri/ =404;
        }

}
````

### 1.6 Copy static website files into the right folder
````
cd /var/www/html/s81/
````
Into this folder copy the index.html and style.css files presents in this project on the folder named 'site' or if you want to create your own website, you are free.

### 1.7 Create a symbolic link of your virtual host config
````
ln -s /etc/nginx/sites-available/s81.conf /etc/nginx/sites-enable/s81.conf
````

### 1.8 Verify the nginx configs
````
sudo nginx -t
````
> **Normally it must return this**
> ````
> nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
> nginx: configuration file /etc/nginx/nginx.conf test is successful
> ````
> It means that every thing is working. If you don't get this message, fix the error before continue

### 1.9. Restart and reload nginx service
````
sudo systemctl restart nginx.service
````

### 1.10. Test your website
````
curl -I http://your.server.ip:81
````
> **You should have this response**
> ````
> HTTP/1.1 200 OK
> Server: nginx/1.24.0 (Ubuntu)
> Date: The date of the day
> Content-Type: text/html
> Content-Length: 490
> Last-Modified: The last modified date
> Connection: keep-alive
> ETag: "69aa6f07-1ea"
> Accept-Ranges: bytes
> ````
> **Everything is Okay**

## 2. On Your local machine
### 2.1. Clone this project on your local machine
````
git clone git@github.com:onomojiji/roadmap.sh-Devops-projects.git
````

### 2.2. Navigate to static site server directory
````
cd static-site-server
````

### 2.3. Copy static website files into a custom folder
````
cd /path/to/your/custom/folder/
````
Into this folder copy the index.html and style.css files presents in this project on the folder named 'site' or if you want to create your own website, you are free.

### 2.4. Make sure that the deploy script is executable
````
sudo chmod +x deploy.sh
````

### 2.5. Edit the html or css file and run the deploy script
````
./deploy.sh
````

This would synchronize your locals changes ti the remote server.

> **Thank you guys.!**