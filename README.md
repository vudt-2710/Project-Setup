# Project Server Setup Automation 

## Using Ansible to set up a server based on the ticket [here](https://dev.sun-asterisk.com/projects/server-request/issues?set_filter=1&tracker_id=4) 

The tasks are separated into different roles, including [user-creation](./roles/user-creation/tasks), [local-config](./roles/local-config/tasks) and [reverse-proxy](./roles/reverse-proxy/tasks)

* In ```user-creation``` will create users, set up group, copy public key and etc 

* In ```local-config``` will change the server IP address, hostname and disable ssh password authentication 

* In ```reverse-proxy``` will create the project config file from this [template](./roles/reverse-proxy/templates/project.j2) then generated a basic authentication (if required) and finally reload nginx config

* ```sotfware``` is in development because some tickets are either using a package manager or script from the internet downloaded by the curl command to install to system-wide or user environment

## Quick Start

Install Ansible with package manager
```bash
sudo apt install ansible
```

Install Ansible with pip (highly recommended)
```
pip install --user ansible ansible-core
```
> If somehow the command is not found, manually create symbolic links to python pip package with this command
```bash
ln -s $SOURCE_FILE $DESTINATION
```

## Running the playbook 
> Before running the playbook, change these [Ansible config](./ansible.cfg) and [inventory](./inventory/servers.ini) respectively. After that, execute this command to start running the playbook

```bash
ansible-playbook setup.yml -vvv
```

## Know Limitations
* The playbook only works with one server because the nature of Ansible when it comes to IP address is static. Furthermore, the template from the company has the same IP address across newly created VMs for example ```192.168.1.2``` or no IP at all, so if the ticket happened to have 2 servers then we will either run each of them one at the time or manually change the IP address of these servers and run the playbook if we want to run it once, thus making this part of the playbook useless
```yml
- name: Changing IP Address
  lineinfile:
    path: /etc/netplan/00-installer-config.yaml
    backrefs: yes
    regexp: '^(\s*)[#]?- {{ ansible_host }}(: )*' 
    line: '\1- {{ item.ipv4 }}/24'
    state: "present"
  loop: "{{ server.info }}"
  register: ip_status

- name: Restart Netplan
  command: netplan apply
  async: 45
  poll: 0
  when: ip_status is changed
```
* Any public key that has a backward slash followed by a character, will be treated as an escape character, in order to resolve this, use double backward slash ```\\```
* The role ```software``` is only intended to use to install package from a package manager (i.e. system packages) or packages that install on user environment 
