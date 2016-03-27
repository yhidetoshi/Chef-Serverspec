Vagrant.configure(2) do |config|
  config.vm.define :chef do |chef|
    chef.vm.box = "Base-OS-Cent"
    config.vm.network "private_network", ip: "192.168.33.10"
  end

  config.vm.define :chef_client1 do |chef_client1|
    chef_client1.vm.box = "Base-OS-Cent"
    config.vm.network "private_network", ip: "192.168.33.11"
  end

  config.vm.define :chef_client2 do |chef_client2|
    chef_client2.vm.box = "Base-OS-Cent"
    config.vm.network "private_network", ip: "192.168.33.12"
  end

end

