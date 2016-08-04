execute "install-td-agent2" do
  command <<-EOH
    sudo curl -L https://toolbelt.treasuredata.com/sh/install-redhat-td-agent2.sh | sh
  EOH
  action :run
end

template "/etc/td-agent/td-agent.conf" do
  source "td-agent.erb"
  user   "root"
  group  "root"
  mode    0755
  variables(
         :host_name => node['host']['name'],
         :host_ip => node['host']['ip'] 
  )
end

service "td-agent" do
  action [:enable, :start]
end
