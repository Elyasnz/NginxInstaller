# Notes
this script will remove old nginx if exists so its a good thing to create backup of your nginx configuration using
```sudo cp /etc/nginx /etc/NginxBackup```

If you use Ubuntu 16.04, 18.04, 20.04, or 20.10, run the following commands to install the latest version of Nginx.<br>
```sudo add-apt-repository ppa:ondrej/nginx-mainline -y && sudo apt update```<br>
By default, only the binary repository is enabled. We also need to enable the source code repository in order to download Nginx source code. Edit the Nginx mainline repository file.<br>
```sudo nano /etc/apt/sources.list.d/ondrej-ubuntu-nginx-mainline-*.list```<br>
Find the line that begins with # deb-src and uncomment it and the run
<br>
```sudo apt update```

# Easy Install
run this command as root <br>
```bash <(curl -Ls https://raw.githubusercontent.com/Elyasnz/NginxInstaller/main/install.sh)```

# WTH is happening
as mentioned in the script you can read the refrences to this script at
* [link1](https://www.linuxbabe.com/security/modsecurity-nginx-debian-ubuntu)
* [link2](https://github.com/openresty/headers-more-nginx-module#installation)

this script will do thease steps (soo simple)
* remove the old Nginx and install new one with the sources from apt
* clone [modsecurity](https://github.com/SpiderLabs/ModSecurity)
* build modsecurity with half of system cpu cores 
* clone [Modsecurity-Nginx](https://github.com/SpiderLabs/ModSecurity-nginx)
* clone [Header-More](https://github.com/openresty/headers-more-nginx-module)
* build nginx with all of thease beautifull modules
* clone [ModSecurity CRS](https://github.com/coreruleset/coreruleset) and add it to ModSecurity
* add ModSecurity to Nginx conf
* set nginx on hold so hopefully nothing breaks in future
* in the end a command will be shown so you can link all configurations in the conf directory to the main Nginx configuration

if your too lazy to copy/paste all the configurations to separate paths in /etc/nginx (like i am) <br>
you can fill them in the conf directory and then by running the linker.sh script a soft link will be created at needed paths at /etc/nginx

Hope you enjoy
