VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
 
 config.vm.define :chef_client1 do |chef_client1|
  chef_client1.vm.box = "Base-OS-Cent"
  config.vm.network "private_network", ip: "192.168.33.10"
 end
 
 config.vm.define :chef_client2 do |chef_client2|
  chef_client2.vm.box = "Base-OS-Cent"
  config.vm.network "private_network", ip: "192.168.33.11"
 end

 config.omnibus.chef_version = :latest
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = "./cookbooks"
    
    chef.run_list = %w[
	recipe[httpd]
    ]
  end
 end
