#! /bin/bash

# Default variable
defaultpass="Aa@123456"
software=("nginx" "mysql" "ruby")	
if [ -f /etc/os-release ];then 
	source /etc/os-release
elif [ -f /lib/os-release ]; then
	source /lib/os-release
fi

# User creation process
local_config() {		
	read -p "Type in the username: " username														
	read -p "Paste in User Public Key: " user_public_key
	useradd -m $username  -s /bin/bash -G $group_name
	mkdir -p /home/$username/.ssh
#	usermod -aG $group_name $username
	echo $user_public_key >/home/$username/.ssh/authorized_keys
	chown -R $username:$username /home/$username/.ssh
	chmod 1700 /home/$username/.ssh 
	chmod 644 /home/$username/.ssh/authorized_keys
	chown -R $username:$username /home/$username/.ssh
	sed "s/PasswordAuthentication yes/PasswordAuthentication no/g" -i /etc/ssh/sshd_config
}

# For APT package management
apt() {
	echo "Detected $PRETTY_NAME which is supported"
	group_name="sudo"
	apt install -y ${software[@]}
	local_config
	echo "$username:$defaultpass" | chpasswd

}

# For YUM package management
yum() {

	echo "Detected $PRETTY_NAME which is supported"
	group_name="wheel"
	local_config
	yum install -y ${software[@]}
	echo $defaultpass | passwd $username --stdin

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

if [[ $ID == "debian" || $ID == "ubuntu" ]]; then
	sed "s/172.16.200.12/$ip/g" -i /etc/netplan/00-installer-config.yaml
elif [[ $ID == "centos" || $ID == "rhel" ]]; then
	sed "s/172.16.200.12/$ip/g" -i /etc/sysconfig/network-scripts/ifcfg-eth0
fi

# After finising all the config this is where the system will reboot it services and itself 
