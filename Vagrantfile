# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.define "containers-from-scratch-1" do |s1|
      s1.vm.box = "ubuntu/xenial64"
      s1.vm.network :private_network, ip: "10.0.0.10"
      s1.vm.hostname = "containers-from-scratch-1"
      s1.vm.provider :virtualbox do |vb|
          vb.customize ['modifyvm', :id, '--nictype1', 'Am79C973']
          vb.customize ["modifyvm", :id, "--nicpromisc1", "allow-all"]
      end
  end
  config.vm.define "containers-from-scratch-2" do |s2|
      s2.vm.box = "ubuntu/xenial64"
      s2.vm.network :private_network, ip: "10.0.0.20"
      s2.vm.hostname = "containers-from-scratch-2"
      s2.vm.provider :virtualbox do |vb|
          vb.customize ['modifyvm', :id, '--nictype1', 'Am79C973']
          vb.customize ["modifyvm", :id, "--nicpromisc1", "allow-all"]
      end
  end
end
