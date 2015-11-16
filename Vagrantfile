# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

	config.vm.box = "AntonioMeireles/coreos-stable"

	config.vm.network :private_network, ip:"192.168.33.10"
	config.vm.hostname = "localhost"

	config.vm.provider "virtualbox" do |vb|
		vb.memory = "1024"
	end

	config.vm.network :forwarded_port, guest: 80, host: 10080 # http
	config.vm.network :forwarded_port, guest: 8080, host: 18080 # http
	config.vm.network :forwarded_port, guest: 8082, host: 18082 # http
	config.vm.network :forwarded_port, guest: 8180, host: 18180 # jenkins
	config.vm.network :forwarded_port, guest: 3000, host: 3000 # rails
	config.vm.network :forwarded_port, guest: 3690, host: 3690 # subversion

	config.vm.synced_folder ".", "/home/core/vagrant-share",
		:create => true, :owner => 'core', :group => 'core',
		:mount_options => ['dmode=777', 'fmode=666']

	config.vm.provision :shell, :inline => <<-PREPARE
		if [ -L .bashrc ]; then
			cp $(readlink .bashrc) .bashrc.new && mv .bashrc.new .bashrc
			chown core:core /home/core/.bashrc
		fi

		if [ ! -e /home/core/packer ]; then
			echo Installing Packer...
			mkdir /home/core/packer
			cd /home/core/packer
			wget https://dl.bintray.com/mitchellh/packer/packer_0.8.6_linux_amd64.zip > /dev/null 2>&1
			unzip packer_0.8.6_linux_amd64.zip > /dev/null 2>&1
			rm packer_0.8.6_linux_amd64.zip
			cd ..
			chown -R core:core packer
			echo "export PATH=\\$PATH:/home/core/packer" >> /home/core/.bashrc
		fi

		if [ ! -e /opt/bin/nomad ]; then
			echo Installing Nomad...
			mkdir -p /opt/bin
			cd /opt/bin
			curl -sSL https://dl.bintray.com/mitchellh/nomad/nomad_0.1.2_linux_amd64.zip -o nomad.zip
			unzip nomad.zip > /dev/null 2>&1
			rm nomad.zip
			chmod +x nomad

			mkdir /etc/nomad.d
			chmod a+w /etc/nomad.d
		fi

		cd /home/core
		git clone https://github.com/imaizm/VagrantEnv03.git
		chown -R core:core VagrantEnv03
	PREPARE

	config.ssh.forward_x11 = true

end