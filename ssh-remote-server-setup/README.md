
## Roadmap.sh-SSH-Remote-Server-Setup 

> Key steps to setup a ssh remote connection with public key 

<https://roadmap.sh/projects/ssh-remote-server-setup>

> #### NB: For this Lab, we used 
> 
> - Ubuntu server 24.04 LTS as the remote server 
> - Windows 11 as the host machine 
> 
> The remote server is a virtual machine created on Oracle VirtualBox. 

For this we will meticulously follow these steps. 

### 1. Ensure that OpenSSH Server is installed on the VM 
> #### 1.1. Update ubuntu packages 
> ```` 
> sudo apt update 
> ```` 

> #### 1.2. Install the Open SSH Server package 
> ```` 
> sudo apt install openssh-server 
> ```` 

Now that the Open SSH server is installed, we move on to generating SSH keys. The goal here is to generate the private key on the host machine and add it to the server as an authorized key. 

### 2. Private key configuration 
> #### 2.1. Private key generation on the host machine 
> *On Powershell or CMD at the location where you want to store the key (In my example: C:\Users\jb.onomo\\.ssh\)* 
> ```` 
> ssh-keygen -t ed25519 -C "BecomeDevopsUbServer" -f C:\Users\jb.onomo\.ssh\devops_vm_key 
> ```` 

Where: 
- -t ed25519 represents the key encoding type 
- -C "BecomeDevopsUbServer" represents the comment or description of the key 
- -f C:\Users\jb.onomo\.ssh\devops_vm_key the location of the files containing the keys 

This will create: 
- devops_vm_key (private key) 
- devops_vm_key.pub (public key) 

> #### 2.2. Display the public key 
> ```` 
> cat C:\Users\jb.onomo\.ssh\devops_vm_key.pub 
> ```` 

This will display a key of the type: 
```` 
ssh-ed25519 AAAAC3NzaXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXhBz+w1sha+ BecomeDevopsUbServer 
```` 

> #### 2.3. Add the private key of our host machine to the list of authorized keys of our Server. 
> > #### 2.3.1. Create the ssh folder if it doesn't exist on our server 
> ```` 
> mkdir -p ~/.ssh 
> ```` 

> #### 2.3.2. Give all rights to the ssh folder to the current user only 
> ```` 
> chmod 700 ~/.ssh 
> ```` 

> #### 2.3.3. Open the file containing the private keys authorized to connect to the server 
> ```` 
> nano ~/.ssh/authorized_keys 
> ```` 
> 
> Then go to a new line and paste the private key generated on the host machine 

> #### 2.3.4. Then give read and write rights on this file only to the current user 
> ```` 
> chmod 600 ~/.ssh/authorized_keys 
> ```` 

### 3. SSH settings configuration on the server For this we need to modify the SSH configuration file 
```` 
sudo nano /etc/ssh/sshd_config 
```` 
In this file, we will uncomment and modify some lines 
```` 
# Port 2222 
# PermitRootLogin no 
# PasswordAuthentication no 
# PubkeyAuthentication yes 
# AuthorizedKeysFile .ssh/authorized_keys 
```` 

- **Port 2222:** this is to define a custom connection port 
- **PermitRootLogin no:** To forbid ssh connection by the root user 
- **PasswordAuthentication no:** To forbid ssh connection by password 
- **PubkeyAuthentication yes:** To allow ssh connection by public key 
- **AuthorizedKeysFile .ssh/authorized_keys:** To specify the authorized keys file Save and close the file. 

### 4. Apply the SSH configuration by restarting the service 
```` 
sudo systemctl restart sshd 
```` 

### 5. And Finally test the connection from the host machine 
```` 
ssh -i C:\Users\jb.onomo\.ssh\devops_vm_key -p 2222 username@192.168.X.X 
```` 
> Where: 
> 
> - **-i C:\Users\jb.onomo\.ssh\devops_vm_key** represents the path to the file containing the private key 
> - **-p 2222** represents the ssh connection port 
> - **username@192.168.X.X** represents the username and IP Address combination 

## As a bonus we install the Brute force attack banner 
### 1. Install the corresponding packages 
```` 
sudo apt update && sudo apt install fail2ban -y 
```` 

### 2. Create a local configuration 
```` 
sudo nano /etc/fail2ban/jail.local 
```` 
Then paste the content below inside the file 
```` 
[DEFAULT] 
bantime = 1h 
findtime = 10m 
maxretry = 3 
banaction = iptables-multiport 
[sshd] 
enabled = true 
port = 2222 
filter = sshd-aggressive 
logpath = /var/log/auth.log 
maxretry = 3 
```` 
> Where: 
> 
> Section [DEFAULT] 
> - **bantime = 1h** represents the duration for which an IP will be banned after exceeding the maximum number of attempts. 
> - **findtime = 10m** indicates the time window during which fail2ban counts failed attempts. If the number of attempts exceeds maxretry within these 10 minutes, the IP is banned. 
> - **maxretry = 3** Maximum number of failed attempts allowed during the findtime period before banning the IP. 
> - **banaction = iptables-multiport** represents the action used to ban the IP. Here, fail2ban will use iptables to block the IP on multiple ports simultaneously. 
> 
> Section [sshd] 
> - **enabled = true** represents the SSH monitoring status 
> - **port = 2222** represents the monitored SSH port. 
> - **filter = sshd-aggressive** represents the filter file used to detect suspicious attempts in the logs. The "sshd-aggressive" filter is stricter than the standard "sshd" filter and bans more quickly. 
> - **logpath = /var/log/auth.log** represents the log file monitored to detect failed SSH connection attempts. 
> - **maxretry = 3** represents the override of the default parameter for this specific jail. 

### 3. Enable the service at startup and restart 
```` 
sudo systemctl enable fail2ban sudo systemctl start fail2ban 
```` 
### 4. Check the status 
```` 
sudo fail2ban-client status sshd 
```` 

At this stage, the service should be started and you can test. If everything is properly installed the command above should return this 
```` 
Status for the jail: sshd
|- Filter
|  |- Currently failed: 0
|  |- Total failed: 0
|  `- File list: /var/log/auth.log
`- Actions
   |- Currently banned: 0
   |- Total banned: 0
   `- Banned IP list: 
```` 

### 5. Some useful commands > #### 5.1 Unban an IP 
> ```` 
> sudo fail2ban-client set sshd unbanip 
> ```` 

> #### 5.2 View the logs 
> ```` 
> sudo tail -f /var/log/fail2ban.log 
> ```` 

> #### 5.3 View ssh connection logs over a period 
> ```` 
> sudo journalctl -u ssh --since "5 minutes ago" >