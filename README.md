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
run this command <br>
```bash -c "$(curl -s "https://raw.githubusercontent.com/Elyasnz/NginxInstaller/main/install")"```

# WTH is happening
* remove the old Nginx and install new one with the sources from apt
* clone [modsecurity](https://github.com/SpiderLabs/ModSecurity)
* build modsecurity with half of system cpu cores 
* clone [Modsecurity-Nginx](https://github.com/SpiderLabs/ModSecurity-nginx)
* clone [Header-More](https://github.com/openresty/headers-more-nginx-module)
* build nginx with all of thease beautifull modules
* clone [ModSecurity CRS](https://github.com/coreruleset/coreruleset) and add it to ModSecurity
* add ModSecurity to Nginx conf
* set nginx on hold so hopefully nothing breaks in future

# Lazy tip
if your too lazy to copy/paste all the configurations to separate paths in /etc/nginx (like i am) <br>
after cloning the repo go the conf directory the fill you configurations in needed files
then just run ```linker``` and it will create a soft link at needed paths in /etc/nginx

# Refrences
* [link1](https://www.linuxbabe.com/security/modsecurity-nginx-debian-ubuntu)
* [link2](https://github.com/openresty/headers-more-nginx-module#installation)


### Hope you enjoy
