execute "add-jenkins-repo" do
  command <<-EOH
    wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
    rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key
  EOH
  action :run
  not_if {::File.exists?("/etc/yum.repos.d/jenkins.repo")}
end
