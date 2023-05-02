#!/usr/bin/env bash

# https://www.linuxbabe.com/security/modsecurity-nginx-debian-ubuntu
# https://github.com/openresty/headers-more-nginx-module#installation

nginx_version="nginx-$(apt-cache policy nginx | sed -nr 's/^.*Candidate: (.*)-.*$/\1/p')"
os_id=$(awk -F= '/^ID=/{print $2}' /etc/os-release)
cpu_count=$(printf '%.*f\n' 0 "$((($(grep -c ^processor /proc/cpuinfo)) / 2))")
echo "Nginx:      " $nginx_version
echo "OS:         " $os_id
echo "Cores Used: " $cpu_count


if [ "$os_id" = "ubuntu" ]; then
  echo "If you use Ubuntu 16.04, 18.04, 20.04, or 20.10, run the following commands to install the latest version of Nginx."
  echo ""
  echo "  sudo add-apt-repository ppa:ondrej/nginx-mainline -y && sudo apt update"
  echo ""
  echo "By default, only the binary repository is enabled. We also need to enable the source code repository in order to download Nginx source code. Edit the Nginx mainline repository file."
  echo "  sudo nano /etc/apt/sources.list.d/ondrej-ubuntu-nginx-mainline-*.list"
  echo "Find the line that begins with # deb-src and uncomment it and the run"
  echo ""
  echo "  sudo apt update"
  echo ""
  echo "would you like to continue?"
  read -n1
else
  echo "Start?"
  read -n1
fi

echo ""
echo "************************************************************"
echo "uninstalling current nginx version"
echo "************************************************************"
echo ""
systemctl stop nginx
apt --purge remove -y nginx* --allow-change-held-packages
rm -rf /etc/nginx
rm -rf /usr/share/nginx
rm -rf /var/log/nginx

mkdir -p /etc/nginx/src
mkdir -p /etc/nginx/modsec
mkdir -p /etc/nginx/modsec-crs

echo ""
echo "************************************************************"
echo "installing nginx"
echo "************************************************************"
echo ""
apt install -y nginx nginx-core nginx-common nginx-full dpkg-dev gcc make build-essential autoconf automake libtool libcurl4-openssl-dev liblua5.3-dev libfuzzy-dev ssdeep gettext pkg-config libpcre3 libpcre3-dev libxml2 libxml2-dev libcurl4 libgeoip-dev libyajl-dev doxygen uuid-dev

# region Nginx source
mkdir -p /etc/nginx/src/nginx
cd /etc/nginx/src/nginx/ || exit
apt source nginx
cd $nginx_version || exit # just to check
# endregion

# region ModSecurity
echo ""
echo "************************************************************"
echo "cloning modsecurity"
echo "************************************************************"
echo ""
git clone --depth 1 -b v3/master --single-branch https://github.com/SpiderLabs/ModSecurity /etc/nginx/src/ModSecurity/
cd /etc/nginx/src/ModSecurity/ || exit

git submodule init
git submodule update

echo ""
echo "************************************************************"
echo "bulding modsecurity"
echo "************************************************************"
echo ""
./build.sh
./configure
make -j"$cpu_count"
make install

cp /etc/nginx/src/ModSecurity/modsecurity.conf-recommended /etc/nginx/modsec/modsecurity.conf
echo 'Include /etc/nginx/modsec/modsecurity.conf' >/etc/nginx/modsec/main.conf
cp /etc/nginx/src/ModSecurity/unicode.mapping /etc/nginx/modsec/
# endregion

# region ModSecurity-Nginx
echo ""
echo "************************************************************"
echo "cloning Modsecurity-Nginx"
echo "************************************************************"
echo ""
git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git /etc/nginx/src/ModSecurity-nginx/
cd /etc/nginx/src/nginx/$nginx_version || exit
apt build-dep nginx -y
# endregion

# region Header-More source
echo ""
echo "************************************************************"
echo "cloning Header-More"
echo "************************************************************"
echo ""
wget https://github.com/openresty/headers-more-nginx-module/archive/refs/tags/v0.33.tar.gz -P /etc/nginx/src/
tar xf /etc/nginx/src/v0.33.tar.gz -C /etc/nginx/src/
mv /etc/nginx/src/headers-more-nginx-module-0.33 /etc/nginx/src/header-more
rm /etc/nginx/src/v0.33.tar.gz
# endregion

# region make nginx
echo ""
echo "************************************************************"
echo "building nginx"
echo "************************************************************"
echo ""
cd /etc/nginx/src/nginx/$nginx_version || exit
./configure --with-compat --add-dynamic-module=/etc/nginx/src/ModSecurity-nginx --add-dynamic-module=/etc/nginx/src/header-more --without-pcre2
make modules
#endregion

# region copy module files to main installation address
cp objs/ngx_http_modsecurity_module.so /usr/share/nginx/modules/
cp objs/ngx_http_headers_more_filter_module.so /usr/share/nginx/modules/
# endregion

# region Modsecurity-OWASP-CRS
echo ""
echo "************************************************************"
echo "cloning ModSecurity core-rule-set"
echo "************************************************************"
echo ""
cd /etc/nginx/modsec-crs || exit
git clone https://github.com/coreruleset/coreruleset /etc/nginx/modsec-crs
mv crs-setup.conf.example crs-setup.conf
mv rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf
mv rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf.example rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf
echo "$(cat /etc/nginx/modsec/main.conf)
Include /etc/nginx/modsec-crs/crs-setup.conf
#Include /etc/nginx/modsec-crs/plugins/*-config.conf
#Include /etc/nginx/modsec-crs/plugins/*-before.conf
Include /etc/nginx/modsec-crs/rules/*.conf
#Include /etc/nginx/modsec-crs/plugins/*-after.conf" >/etc/nginx/modsec/main.conf

# endregion

# region modify nginx.conf
echo "load_module modules/ngx_http_modsecurity_module.so;
load_module modules/ngx_http_headers_more_filter_module.so;
$(cat /etc/nginx/nginx.conf)" >/etc/nginx/nginx.conf

# endregion
echo ""
echo "************************************************************"
echo "cloning ModSecurity core-rule-set"
echo "************************************************************"
echo ""
echo "add these lines to http section"
echo "  modsecurity on;"
echo "  modsecurity_rules_file /etc/nginx/modsec/main.conf;"


nginx -t
apt-mark hold nginx
systemctl stop nginx
#sudo systemctl start nginx

echo ""
echo "************************************************************"
echo "Nginx+ModSecurity+CRS+HeaderMore Installed"
echo "************************************************************"

