#
# Cookbook:: wayneweb
# Recipe:: default
# Version:: 2.0
# Copyright:: 2018, The Authors, All Rights Reserved.

# -- Install python 3, django, uwsgi, and any other required packages

bash 'yum groupinstall Development' do
  user "root"
  group "root"
  code <<-EOC
    yum groupinstall "Development" -y
  EOC
  not_if "yum grouplist installed | grep 'Development'"
end

bash 'yum install ius-release' do
  user "root"
  group "root"
  code <<-EOC
     yum install "https://centos7.iuscommunity.org/ius-release.rpm" -y
  EOC
  not_if "yum list installed | grep 'ius-release'"
end

yum_package %w(python36u python36u-pip python36u-devel) do
  action :install
end

bash 'pip3.6 install Django' do
  user "root"
  group "root"
  code <<-EOC
    pip3.6 install "Django" -q
  EOC
  not_if "pip3.6 list | grep 'Django'"
end

bash 'pip3.6 install uwsgi' do
  user "root"
  group "root"
  code <<-EOC
    pip3.6 install "uwsgi" -q
  EOC
  not_if "pip3.6 list | grep 'uWSGI'"
end

# -- Setup App Folders and Files

remote_directory "/var/www/waynetest" do
  source "waynetest"
  owner "root"
  group "root"
  mode 0774
  action :create
end

# -- Run Django

bash 'uwsgi run' do
  user "root"
  group "root"
  code <<-EOC
    gnome-terminal -e "bash -c '
	cd /var/www/waynetest/src/capstoneweb/	
	uwsgi --socket :8080 --module capstoneweb.wsgi --uid root; exec $SHELL'"
    EOC
end

# -- Disable automatic updates

service 'packagekit' do
   action [:stop, :disable]
end

# -- Setup Firewall rules

bash 'firewalld rule 1' do
   user 'root'
   group 'root'
   code <<-EOC
      'firewall-cmd --zone=public --add-service=http'
   EOC
   not_if 'firewall-cmd --zone=public --list-all | grep http'
end

bash 'firewalld rule 2' do
   user 'root'
   group 'root'
   code <<-EOC
      'firewall-cmd --zone=public --add-service=https'
   EOC
   not_if 'firewall-cmd --zone=public --list-all | grep https'
end

# -- Setup Nginx

package 'nginx' do
   action :install
end

# Sets the SELinux boolean to allow httpd to make network connections
execute 'set_httpd_can_network_connect_true' do
  command 'setsebool -P httpd_can_network_connect true'
  not_if 'getsebool httpd_can_network_connect | grep -q -- "--> on"'
end

template '/etc/nginx/nginx.conf' do
  source "nginx/nginx.conf"
  owner "root"
  group "root"
  mode 0774
  action :create
end

# -- Setup nginx sites

bash 'Setup Nginx sites' do
  user "root"
  group "root"
  code <<-EOC
	mkdir /etc/nginx/sites-available
	mkdir /etc/nginx/sites-enabled
  EOC
     not_if 'test -d "/etc/nginx/sites-available" && test -d "/etc/nginx/sites-enabled"'
end

# Set up symbolic link

bash 'Setting up sites-available & site-enabled' do
  user "root"
  group "root"
  code <<-EOC
    cp /var/www/waynetest/conf/waynetest.conf /etc/nginx/sites-available/waynetest.conf
    ln -s /etc/nginx/sites-available/waynetest.conf /etc/nginx/sites-enabled/waynetest.conf
  EOC
    not_if 'ls /etc/nginx/sites-enabled/ | grep waynetest.conf'
end

# -- Start service

service 'nginx' do
  action [:enable, :start]
end

# -- DL & Configure MariaDBClient

bash 'pip install mariadbclient' do
  user 'root'
  group 'root'
  code <<-EOC
     pip install "mysqlclient" -q
     yum intall mariadb-devel -y
  EOC
    not_if "pip3.6 list | grep mysqlclient && yum list installed | grep mariadb-devel"
end

# Pull down script that sets up DB user and test poll question and answer

cookbook_file '/bin/djangodeploy.sh' do
    source '/scripts/djangodeploy.sh'
    user 'root'
    group 'root'
    mode 0700
    action :create
end

# -- Migrate DB

bash 'Migrate DB' do
   user 'root'
   group 'root'
   code <<-EOC
     cd /var/www/waynetest/src/capstoneweb
     python3.6 manage.py migrate
   EOC
end
