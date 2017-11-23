# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.define "containers-from-scratch" do |s1|
      s1.vm.box = "ubuntu/xenial64"
      s1.vm.network :private_network, ip: "10.0.0.10"
      s1.vm.hostname = "containers-from-scratch"
  end
end
