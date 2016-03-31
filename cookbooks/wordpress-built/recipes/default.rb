execute "get-file-wordpress" do
    user "root"
    command <<-EOH
	git clone #{node['file']['wordpress']} #{node['path']['wordpress']}
        chown -R #{node['web']['name']}:#{node['web']['name']} #{node['path']['wordpress']}
    EOH
end

bash 'mysql_secure_instal' do
  code <<-"EOH"
    /usr/bin/mysqladmin drop test -f
    /usr/bin/mysql -e "delete from user where user = '';" -D mysql
    /usr/bin/mysql -e "delete from user where user = 'root' and host = \'#{node[:hostname]}\';" -D mysql
    /usr/bin/mysql -e "SET PASSWORD FOR 'root'@'::1' = PASSWORD('#{node['wordpress']['mysql_pw']}');" -D mysql
    /usr/bin/mysql -e "SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('#{node['wordpress']['mysql_pw']}');" -D mysql
    /usr/bin/mysql -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('#{node['wordpress']['mysql_pw']}');" -D mysql
    /usr/bin/mysqladmin flush-privileges -p#{node['wordpress']['mysql_pw']}
  EOH
  action :run
  only_if "/usr/bin/mysql -u root -e 'show databases;'"
end


template "sql-for-wordpress" do
  path "/tmp/wordpress.sql"
  source "wordpress.sql.erb"
  mode 0644
  variables(
          :db_name => node['mysql']['db_name'],
          :db_user => node['mysql']['user']['name'],
          :db_pass => node['mysql']['user']['password']
   )
end
 
execute "mysql-create-user" do
    command "mysql -u root -p#{node['wordpress']['mysql_pw']} < /tmp/wordpress.sql"
    action :run
end

# set_wordpress_config
template "/var/www/wordpress/wp-config.php" do
   source "wp-config.php.erb"
   owner "nginx"
   group "nginx"
   mode 0644
   variables(
         :db_name => node['mysql']['db_name'],
         :db_user => node['mysql']['user']['name'],
         :db_pass => node['mysql']['user']['password']
  )
end
