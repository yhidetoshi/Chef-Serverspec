cookbook_file "/etc/yum.repos.d/docker.repo" do
 mode 644
 user "root"
 group "root"
 not_if {::File.exists?("/etc/yum.repos.d/docker.repo")}
end
