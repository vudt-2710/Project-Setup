#! /bin/bash

# Default variable
defaultpass="Aa@123456"		
source /etc/os-release

# User creation process
local_config() {		
	read -p "Type in the username: " username														
	read -p "Paste in User Public Key: " user_public_key
	sudo useradd -m $username  -s /bin/bash -G $group_name
	sudo mkdir -p /home/$username/.ssh
#	sudo usermod -aG $group_name $username
	sudo echo $user_public_key >/home/$username/.ssh/authorized_keys
	sudo chown -R $username:$username /home/$username/.ssh
	sudo chmod 1700 /home/$username/.ssh 
	sudo chmod 644 /home/$username/.ssh/authorized_keys
	sudo chown -R $username:$username /home/$username/.ssh
	sudo sed "s/PasswordAuthentication yes/PasswordAuthentication no/g" -i /etc/ssh/sshd_config
}

# For APT package management
apt() {
	echo "Detected $PRETTY_NAME which is supported"
	group_name="sudo"
	local_config
	sudo echo "$username:$defaultpass" | chpasswd

}

# For YUM package management
yum() {

	echo "Detected $PRETTY_NAME which is supported"
	group_name="wheel"
	local_config
	sudo echo $defaultpass | passwd $username --stdin

}

# Keep asking for new user creation until the input is no
read -p "Do you wish to create new user? (yes[y]/no[n]) " create

if [[ $create == "no" || $create == "n" ]]; then
	exit 1
else
	while [[ $create == "yes" || $create == "y" ]]; do
		if [[ $ID == "debian" || $ID == "ubuntu" ]]; then
			apt
		elif [[ $ID == "centos" || $ID == "rhel" ]]; then
			yum
		else
			echo "Unsupported Distribution"
		fi
		read -p "Do you wish to create new user? (yes[y]/no[n]) " create
	done
fi

# Finally changing the hostname and ip address corresponding to the ticket
echo "This session will reboot in order for this to take effect"
read -p "The Hostname of this VM: " host_name
read -p "The Designated IP Address of this VM: " ip
sudo sed "s/template/$host_name/g" -i /etc/hostname

if [[ $ID == "debian" || $ID == "ubuntu" ]]; then
	sudo sed "s/172.16.200.12/$ip/g" -i /etc/netplan/00-installer-config.yaml
elif [[ $ID == "centos" || $ID == "rhel" ]]; then
	sudo sed "s/172.16.200.12/$ip/g" -i /etc/sysconfig/network-scripts/ifcfg-eth0
fi

# After finising all the config this is where the system will reboot it services and itself 
sudo systemctl reboot now
