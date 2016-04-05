include_recipe "docker-install::add-repo"

package "install docker modules" do
  package_name ['docker-io', 'device-mapper-libs']
  action :install
end

service "docker" do
 action [:enable, :start]
end

