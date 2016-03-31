package "mysql-server" do
  action :install
  not_if 'which mysqld'
end

service "mysqld" do
 action [:enable, :start]
 supports :status => true, :restart => true, :reload => true
end

