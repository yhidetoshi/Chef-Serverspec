Vagrant.configure(2) do |config|

  config.vm.define :chef do |chef|
    chef.vm.box = "Base-OS-Cent"
    config.vm.network "private_network", ip: "192.168.33.10"
  end

  config.vm.define :chef_client3 do |chef_client3|
    chef_client3.vm.box = "Base-OS-Cent"
    config.vm.network "private_network", ip: "192.168.33.13"
  end
end

