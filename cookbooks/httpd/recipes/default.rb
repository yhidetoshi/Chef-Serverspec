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

cookbook_file "/usr/local/hogehoge/test_cookbook_file.txt" do
 mode 755
end

=begin
template "httpd.conf" do
 path "/etc/httpd/conf/httpd.conf"
 owner "root"
 group "rout"
 mode 0644
 notifies :reload, 'service[httpd]'
end
=end
