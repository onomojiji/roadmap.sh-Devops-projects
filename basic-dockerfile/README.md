# Basic Dockerfile

> ## Prerequires
> For this projet, make sure that you have docker engine installed on your machine
> 
> To check if you have docker installed on your machine, type on your terminal (Powershell, Bash or Other)
> ````
> docker -v
> ````
> If it is installed. you will see a thing like this
> ````
> Docker version 29.1.3, build f52814d
> ````
> If docker is not installed, install it 
> In my case i'm using ubuntu linux operating system, then to install just type
> ````
> sudo apt update | sudo apt install docker.io -y
> ````
> To run docker commands without sudo
> ````
> sudo groupadd docker
> ````
> ````
> sudo usermod -aG docker $USER
> `````
> ````
> newgrp docker
> ````
> If you are using other operating system follow the steps on theses links
> #### 1. Windows OS
> [https://docs.docker.com/desktop/setup/install/windows-install/](https://docs.docker.com/desktop/setup/install/windows-install/)
> #### 2. Mac OS
> [https://docs.docker.com/desktop/setup/install/mac-install/](https://docs.docker.com/desktop/setup/install/mac-install/)

> **To run this project, you need to follow the steps bellow**

## 1. Create a project folder
````
mkdir basic-dockerfile
````

## 2. Create a dockerfile and copy my content in yours
````
cd basic-dockerfile
````
````
vim Dockerfile
````

## 3. Build the docker image with custom argument value
````
docker build --build-arg NAME=ONOMO -t hello-captain .
````

> #### NB : 
> - You can replace 'ONOMO' with your own name or other custom name
> - You can replace 'hello-captain' with another image name

## 4. Run a docker container with the image
````
docker run hello-captain
````

> **Thank you guys.!**