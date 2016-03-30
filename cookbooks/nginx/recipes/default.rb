case node[:platform]
 when 'redhat', 'centos'
  package "nginx" do
    action :install
  not_if 'which nginx'
 end
end

service "nginx" do
 action [:enable, :start]
 supports :status => true, :restart => true, :reload => true
end

template "/etc/nginx/conf.d/wp.conf" do
  source "wordpress.conf.erb"
  owner "root"
  group "root"
  mode 0644
  variables({
	:hostname => `/bin/hostname`.chomp	
  })
end

