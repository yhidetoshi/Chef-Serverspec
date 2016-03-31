package "git" do
  action :install
 not_if 'which git'
end



