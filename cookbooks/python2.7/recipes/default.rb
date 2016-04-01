=begin
install_packages = %w[
	zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel
]

install_packages.each do |pkg|
   bash "install_#{pkg}" do
	user "root"
  	code <<-EOC
          yum -y install #{pkg}
        EOC
   end
end
=end

package 'install package for compile' do
  package_name ['zlib-devel', 'bzip2-devel', 'openssl-devel', 'ncurses-devel', 'sqlite-devel', 'readline-devel', 'tk-devel']
  action :install
end

execute "download and install python2.7" do
  user "root"
  command <<-EOH
    git clone #{node['file']['download']} #{node['path']['file']}
    #{node['path']['file']}/configure --prefix=#{node['path']['prefix']}
    make && make install
    mv #{node['to']['ln']} /usr/bin/python_old
    ln -s #{node['from']['ln']} #{node['to']['ln']}
  EOH
end

template "/usr/bin/yum" do
  source "yum.erb"
  owner "root"
  group "root"
  mode 0751
end
