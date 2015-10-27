# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

	config.vm.box = "AntonioMeireles/coreos-stable"

	config.vm.network :private_network, ip:"192.168.33.10"
	config.vm.hostname = "localhost"

	config.vm.network :forwarded_port, guest: 80, host: 10080 # http
	config.vm.network :forwarded_port, guest: 8080, host: 18080 # http
	config.vm.network :forwarded_port, guest: 8082, host: 18082 # http
	config.vm.network :forwarded_port, guest: 8180, host: 18180 # jenkins
	config.vm.network :forwarded_port, guest: 3000, host: 3000 # rails
	config.vm.network :forwarded_port, guest: 3690, host: 3690 # subversion

	config.vm.synced_folder "packer-scripts", "/home/core/packer-scripts", :create => true, :owner => 'core', :group => 'core', :mount_options => ['dmode=777', 'fmode=666']

	config.vm.provision :shell, :inline => <<-PREPARE
		if [ ! -e /home/core/packer ]; then
			mkdir /home/core/packer
			cd /home/core/packer
			wget https://dl.bintray.com/mitchellh/packer/packer_0.8.6_linux_amd64.zip
			unzip packer_0.8.6_linux_amd64.zip
			cd ..
		fi
		if [ -L .bashrc ]; then
			cp $(readlink .bashrc) .bashrc.new && mv .bashrc.new .bashrc
			echo "export PATH=$PATH:/home/core/packer" >> /home/core/.bashrc
		fi
	PREPARE

	config.ssh.forward_x11 = true

end
