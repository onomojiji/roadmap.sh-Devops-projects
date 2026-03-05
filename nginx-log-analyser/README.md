# Nginx Logs Analyzer

> ### Prerequires
> 
> You should have python3 installed on your machine
>
> **if it is not the case, install it first before**
>
> **And then follow the steps bellow**

## 1. Clone this project
````
git clone git@github.com:onomojiji/roadmap.sh-Devops-projects.git
````

## 2. Navigate to the nginx logs analyzer folder
````
cd nginx-log-analyzer
````

## 3. On this folder, download the nginx-acces.log file
````
wget https://gist.githubusercontent.com/kamranahmedse/e66c3b9ea89a1a030d3b739eeeef22d0/raw/77fb3ac837a73c4f0206e78a236d885590b7ae35/nginx-access.log
````

## 4. Make the nginx-logs-analyzer.py script executable
````
sudo chmod +x nginx-logs-analyzer.py
````

## 5. Run the python script
````
python3 nginx-logs-analyzer.py
````

> Thank you guys