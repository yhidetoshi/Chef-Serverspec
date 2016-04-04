package "wget" do
  action :install
  not_if "which wget"
end

