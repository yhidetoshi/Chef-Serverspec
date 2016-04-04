include_recipe "docker-install::add-repo"

package "docker-io" do
  action :install
end

service "docker" do
 action [:enable, :start]
end

