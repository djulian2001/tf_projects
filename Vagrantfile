Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
  end

  config.vm.provision "shell", inline: <<-SHELL
    sudo yum -y update
    sudo yum -y install epel-release
    sudo yum --enablerepo=epel -y install epel-release

    # software dependency
  	sudo yum -y install awscli.noarch unzip.x86_64

  	curl --get --output /home/vagrant/terraform.zip https://releases.hashicorp.com/terraform/0.12.0/terraform_0.12.0_linux_amd64.zip
  	unzip /home/vagrant/terraform.zip
  	sudo mv /home/vagrant/terraform /usr/local/bin/

  SHELL

  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"

end
