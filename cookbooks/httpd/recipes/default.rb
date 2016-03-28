case node[:platform]
 when 'redhat', 'centos'
   package "httpd" do
     action :install
   not_if 'which httpd'
 end
 
 when 'debian', 'ubuntu'
   package "apache2" do
    action :install
   not_if 'which apache'
 end
end

directory '/usr/local/hogehoge/' do
 owner 'vagrant'
 group 'vagrant'
 mode 0755
 action :create
end

service "httpd" do
 action [:enable, :start]
 supports :status => true, :restart => true, :reload => true
end
