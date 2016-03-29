VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
 
  config.vm.define :chef_client1 do |chef_client1|
    chef_client1.vm.box = "Base-OS-Cent"
    chef_client1.vm.hostname = "chef-client1"
    chef_client1.vm.network "private_network", ip: "192.168.33.10"

    chef_client1.vm.provider "virtualbox" do |v1|
	v1.customize ["modifyvm", :id, "--cpus", "2"]
	v1.memory = 512
    end
  end
 

  config.vm.define :chef_client2 do |chef_client2|
    chef_client2.vm.box = "Base-OS-Cent"
    chef_client2.vm.hostname = "chef-client2"
    chef_client2.vm.network "private_network", ip: "192.168.33.11"
    
    chef_client2.vm.provider "virtualbox" do |v2|
	v2.cpus = 1
	v2.memory = 512
    end
  end

 config.omnibus.chef_version = :latest
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = "./cookbooks"
    
    chef.run_list = %w[
	recipe[httpd]
    ]
  end
 end
