yum_package "java-1.8.0-openjdk.x86_64" do
  action :install
  not_if "which java"
end
