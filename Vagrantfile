# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

	config.vm.box = "AntonioMeireles/coreos-stable"

	config.vm.network :private_network, ip:"192.168.33.10"
	config.vm.hostname = "localhost"

	config.vm.provider "virtualbox" do |vb|
		vb.memory = "1024"
	end

	config.vm.network :forwarded_port, guest: 8500, host: 18500 # consul ui

	config.vm.synced_folder ".", "/home/core/vagrant-share",
		:create => true, :owner => 'core', :group => 'core',
		:nsf => {:mount_options => ['dmode=777', 'fmode=666']}

	config.vm.provision :shell, :inline => <<-PREPARE
		if [ -L .bashrc ]; then
			cp $(readlink .bashrc) .bashrc.new && mv .bashrc.new .bashrc
			chown core:core /home/core/.bashrc
		fi

	#	if [ ! -e /home/core/go ]; then
	#		echo Installing Go...
	#		cd /home/core
	#		curl -sSL https://storage.googleapis.com/golang/go1.5.1.linux-amd64.tar.gz -o go.tar.gz
	#		tar zxf go.tar.gz
	#		rm go.tar.gz
	#		chown -R core:core go
	#
	#		mkdir go-work
	#		chown core:core go-work
	#
	#		echo "export GOROOT=/home/core/go" >> /home/core/.bashrc
	#		echo "export GOPATH=/home/core/go-work" >> /home/core/.bashrc
	#		echo "export PATH=\\$PATH:\\$GOROOT/bin" >> /home/core/.bashrc
	#	fi

		if [ ! -e /home/core/packer ]; then
			echo Installing Packer...
			mkdir /home/core/packer
			cd /home/core/packer
			curl -sSL https://releases.hashicorp.com/packer/0.8.6/packer_0.8.6_linux_amd64.zip -o packer.zip
			unzip packer.zip > /dev/null 2>&1
			rm packer.zip
			cd ..
			chown -R core:core packer
			echo "export PATH=\\$PATH:/home/core/packer" >> /home/core/.bashrc
		fi

		if [ ! -e /opt/bin/consul ]; then
			echo Installing Consul...
			if [ ! -e /opt/bin ]; then
				mkdir -p /opt/bin
			fi
			cd /opt/bin
			curl -sSL https://releases.hashicorp.com/consul/0.5.2/consul_0.5.2_linux_amd64.zip -o consul.zip
			unzip consul.zip > /dev/null 2>&1
			rm consul.zip
			chmod +x consul

			mkdir /tmp/consul
			chmod 777 /tmp/consul
		fi
		
		if [ ! -e /home/core/consul-web-ui ]; then
			echo Installing Consul Web UI...
			mkdir /home/core/consul-web-ui
			cd /home/core/consul-web-ui
			curl -sSL https://releases.hashicorp.com/consul/0.5.2/consul_0.5.2_web_ui.zip -o consul-web-ui.zip
			unzip consul-web-ui.zip > /dev/null 2>&1
			rm consul-web-ui.zip
			cd ..
			chown -R core:core consul-web-ui
		fi
		
	#	if ! ps -a | grep -e "consul" > /dev/null 2>&1; then
	#		echo Stating Consul...
	#		su core -c "nohup /opt/bin/consul agent -server -bootstrap-expect 1 -data-dir /tmp/consul -ui-dir /home/core/consul-web-ui/dist > /tmp/consul.out 2>&1 &"
	#	fi

		if [ ! -e /opt/bin/nomad ]; then
			echo Installing Nomad...
			if [ ! -e /opt/bin ]; then
				mkdir -p /opt/bin
			fi
			cd /opt/bin
			curl -sSL https://releases.hashicorp.com/nomad/0.2.3/nomad_0.2.3_linux_amd64.zip -o nomad.zip
			unzip nomad.zip > /dev/null 2>&1
			rm nomad.zip
			chmod +x nomad

			mkdir /etc/nomad.d
			chmod a+w /etc/nomad.d
		fi

		if [ ! -e /home/core/VagrantEnv03 ]; then
			cd /home/core
			su core -c "git clone https://github.com/imaizm/VagrantEnv03.git"
		else
			echo Updating git repo...
			cd /home/core/VagrantEnv03
			su core -c "git pull"
		fi
		
		if ! docker images | grep -e "imaizm/web-front" -e "0.1" > /dev/null 2>&1; then
			echo packer build machine_web-front.json
			cd /home/core/VagrantEnv03/packer-scripts
			su core -c "/home/core/packer/packer build machine_web-front.json"
		fi
		
	PREPARE

#	config.ssh.forward_x11 = true

end

### Memo
=begin
cd vagrant-share/packer-scripts
packer build machine_web-front.json
docker build -t imaizm/web-front:0.1_with_cmd /home/core/vagrant-share/packer-scripts/dockerfiles/web-front/
docker run -d -p 8080:80 imaizm/web-front:0.1_with_cmd
cd
nohup consul agent -server -bootstrap-expect 1 -data-dir /tmp/consul -ui-dir /home/core/consul-web-ui/dist -client=0.0.0.0 > /tmp/consul.out 2>&1 &
sudo nohup nomad agent -dev > /tmp/nomad.out 2>&1 &
cd vagrant-share/nomad-scripts
nomad run /home/core/vagrant-share/nomad-scripts/docker_without_cmd.hcl
nomad run /home/core/vagrant-share/nomad-scripts/docker_with_cmd.hcl
curl -s http://127.0.0.1:8500/v1/catalog/nodes  | jq '.'
curl -s http://127.0.0.1:8500/v1/catalog/services  | jq '.'
curl -s http://127.0.0.1:8500/v1/catalog/service/example-web-httpd  | jq '.'
curl -s http://127.0.0.1:8500/v1/catalog/service/web  | jq '.'
dig @127.0.0.1 -p 8600 example-web-httpd.service.consul
dig @127.0.0.1 web.service.consul

consul agent -data-dir=/tmp/consul -server -bootstrap-expect 2 &

# CoreOs /usr/lib64/systemd/system/docker.service
[Unit]
Description=Docker Application Container Engine
Documentation=http://docs.docker.com
After=docker.socket early-docker.target network.target
Requires=docker.socket early-docker.target

[Service]
EnvironmentFile=-/run/flannel_docker_opts.env
MountFlags=slave
LimitNOFILE=1048576
LimitNPROC=1048576
ExecStart=/usr/lib/coreos/dockerd daemon --host=fd:// $DOCKER_OPTS $DOCKER_OPT_BIP $DOCKER_OPT_MTU $DOCKER_OPT_IPMASQ

[Install]
WantedBy=multi-user.target

# /usr/share/oem/cloud-config.yml

    - name: docker.service
      command: start
      content: |
        [Unit]
        Description=Docker Application Container Engine
        Documentation=http://docs.docker.com
        After=docker.socket early-docker.target network.target
        Requires=docker.socket early-docker.target
        
        [Service]
        Environment="DOCKER_OPTS=--dns 172.17.42.1 --dns 8.8.8.8 --dns-search service.consul"
        EnvironmentFile=-/run/flannel_docker_opts.env
        MountFlags=slave
        LimitNOFILE=1048576
        LimitNPROC=1048576
        ExecStart=/usr/lib/coreos/dockerd daemon --host=fd:// $DOCKER_OPTS $DOCKER_OPT_BIP $DOCKER_OPT_MTU $DOCKER_OPT_IPMASQ
        
        [Install]
        WantedBy=multi-user.target

#
--dns 172.17.42.1 --dns `grep nameserver /etc/resolv.conf|head -1|awk '{print $2}'` --dns-search service.consul

=end
