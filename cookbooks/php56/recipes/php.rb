install_packages = %w[
	php php-mbstring php-mysql php56 php-fpm
]

install_packages.each do |pkg|
  bash "install_#{pkg}" do
	user "root"
  	code <<-EOC
          yum -y install #{pkg}
        EOC
   end
end

service "php-fpm" do
  action [:enable, :start]
  supports :status => true, :restart => true, :reload => true
end

#set up php.ini
template "/etc/php.ini" do
  source "php.ini.erb"
  owner "root"
  group "root"
  mode 0644
end

#set up php-fpm
template "/etc/php-fpm.d/www.conf" do
  source "www.conf.erb"
  owner "root"
  group "root"
  mode 0644
  variables(
	:web_name => node['web']['name']
)
end
