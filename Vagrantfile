# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  config.ssh.insert_key = false

  # vagrant-vbguest
  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = true # Guest Additionsの自動アップデート
    config.vbguest.no_remote = true # Guest Additionsのisoファイルをリモートからダウンロード
  end

  # vagrant-cachier
  # http://fgrehm.viewdocs.io/vagrant-cachier/usage/
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end

  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "bento/centos-7"
  config.vm.box_url = "https://vagrantcloud.com/bento/centos-7"
  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"
  config.vm.network :forwarded_port, guest: 22, host: 2222

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"



  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL


  config.omnibus.chef_version=:latest
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = './chef-repo/cookbooks'
    chef.add_recipe 'web'
    chef.add_recipe 'mariadb'
    chef.add_recipe 'laravel'
    chef.add_recipe 'laravel::configure_database'
    chef.add_recipe 'xdebug'
  end

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"
  config.vm.synced_folder "./", "/var/app",
                          type: "rsync",
                          owner: "vagrant",
                          group: "vagrant",
                          rsync__args: [
                              "--compress",
                              "--verbose",
                              "--archive",
                              "--delete",
                              "--copy-links",
                              "--chmod=Du=rwx,Dgo=rx,Fu=rwx,Fog=rx",
                          ],
                          rsync__auto: true,
                          rsync__chown: true,
                          rsync__exclude: ["./laravelapp/storage", "./.idea", "./.git", "./.vagrant"],
                          rsync__verbose: true

  # config.vm.synced_folder "./", "/var/app",
  #                         create: true,
  #                         type: "nfs"

  # config.vm.bindfs.bind_folder "/host_mount","/var/apps",
  # :owner => "vagrant",
  # :group => "vagrant",
  # :'create-as-user' => true,
  # :perms => "u=rwx:g=rwx:o=rwx",
  # :'create-with-perms' => "u=rwx:g=rwx:o=rwx",
  # :'chown-ignore' => true,
  # :'chgrp-ignore' => true,
  # :'chmod-ignore' => true

  # config.nfs.map_uid = :auto
  # config.nfs.map_gid = :auto
  # config.nfs.map_uid = 'okuyama'
  # config.nfs.map_gid = 'staff'
  #
  # config.vm.provision "shell", run: "always", inline: "chmod -R 777 /var/app/laravelapp/storage"

end
