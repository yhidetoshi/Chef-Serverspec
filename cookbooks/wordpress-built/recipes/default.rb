execute "get-file-wordpress" do
    user "root"
    command <<-EOH
	git clone #{node['file']['wordpress']} #{node['path']['wordpress']}
        chown -R #{node['web']['name']}:#{node['web']['name']} #{node['path']['wordpress']}
    EOH
end

template "sql-for-wordpress" do
  path "/tmp/wordpress.sql"
  source "wordpress.sql.erb"
  mode 0644
end
 
execute "mysql-create-user" do
    command "mysql -u root -p#{mysql_pw} < /tmp/wordpress.sql"
    action :run
end
