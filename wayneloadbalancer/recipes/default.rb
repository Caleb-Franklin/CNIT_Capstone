#
# Cookbook:: wayneloadbalancer
# Recipe:: default
# Version:: 1.0
# Copyright:: 2018, The Authors, All Rights Reserved.

# -- setup HAProxy

bash 'haproxy install' do
   user 'root'
   group 'root'
   code <<-EOC
	yum install -y haproxy
   EOC
   not_if "yum list installed | grep haproxy"
end

# -- Configure SSL

directory '/etc/ssl/private' do
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

cookbook_file '/etc/ssl/private/waynetest-local.cnf' do
  source "sslconfig/waynetest-local.cnf"
  owner "root"
  group "root"
  mode 0774
  action :create
end

# -- Setup the cert's

bash 'SSL configuration' do
   user 'root'
   group 'root'
   code <<-EOC
	cd /etc/ssl/private
	openssl genrsa -des3 -passout pass:ciscopass1 -out server.pass.key 2048
	openssl rsa -passin pass:ciscopass1 -in server.pass.key -out waynetest.local.key
	rm -f server.pass.key
	openssl req -new -key waynetest.local.key -config waynetest-local.cnf -out waynetest.local.csr
        sleep .5	  
	openssl x509 -req -days 365 -in waynetest.local.csr -extfile waynetest-local.cnf -extensions req_ext -signkey waynetest.local.key -out waynetest.local.crt
        sleep .5
	cat waynetest.local.crt waynetest.local.key > waynetest.local.pem
    EOC
	not_if 'ls /etc/ssl/private | grep waynetest.local.pem'
end
# -- Modify Config HAProxy

cookbook_file '/etc/haproxy/haproxy.cfg' do
  source "haproxy/haproxy.cfg"
  owner "root"
  group "root"
  mode 0774
  action :create
end

# -- disable selinux

bash 'Disable selinux' do
   user 'root'
   group 'root'
   code <<-EOC
     setenforce 0
   EOC

end

# -- restart HAproxy

service 'haproxy' do
  action :restart
end
