#
# Cookbook:: wayneMariadb
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

# -- setup database

yum_package %w(mariadb-server mariadb) do
  action :install
end

service 'mariadb' do
   action :start
end

# -- Setup Mariadb secure_installation and setup

bash 'Secure Mariadb' do
   user 'root'
   group 'root'
   code <<-EOC
	    mysql --user="root" -e "UPDATE mysql.user SET Password=PASSWORD('ciscopass1') WHERE User = 'root';"
	    mysql --user="root" -e "DROP USER ''@'localhost';"
	    mysql --user="root" -e "DROP USER ''@'$(hostname)';"
	    mysql --user="root" -e "DROP DATABASE IF IT EXISTS test;"
	    mysql --user="root" -e "FLUSH PRIVILEGES;"
   EOC
   only_if "mysqladmin --user=root status > /dev/null 2>&1"
end

bash 'Creating DB Mariadb' do
   user 'root'
   group 'root'
   code <<-EOC
	mysql --user="root" --password='ciscopass1' -e "CREATE DATABASE webapp;"
	mysql --user="root" --password='ciscopass1' -e "CREATE USER 'webappuser'@'%' IDENTIFIED BY 'stoutcapstone';"
	mysql --user="root" --password='ciscopass1' -e "GRANT ALL PRIVILEGES ON webapp.* TO 'webappuser'@'%' IDENTIFIED BY 'stoutcapstone' WITH GRANT OPTION;"
	mysql --user="root" --password='ciscopass1' -e "FLUSH PRIVILEGES;"
   EOC
   not_if "test -d /var/lib/mysql/webapp"
end

# -- Start Mariadb

service 'mariadb' do
   action :start
end
