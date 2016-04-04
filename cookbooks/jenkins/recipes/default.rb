include_recipe "wget"
include_recipe "nginx::jenkins"

execute "add-jenkins-repo" do
  command <<-EOH
    wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
    rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key
  EOH
  action :run
  not_if {::File.exists?("/etc/yum.repos.d/jenkins.repo")}
end

package "jenkins" do
  action :install
end

template "/etc/sysconfig/jenkins" do
  source "jenkins.erb"
  user "root"
  group "root"
  mode 0600
  variables(
	:jdk_path => node['jdk']['path'],
	:prefix => node['prefix']['path']
  )
end


service "jenkins" do
  action [:enable, :start]
end

