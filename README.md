# Project Server Setup Automation 

## Using Ansible to set up a server based on the ticket [here](https://dev.sun-asterisk.com/projects/server-request/issues?set_filter=1&tracker_id=4) 

The tasks are separated into different roles, including [user-creation](./roles/user-creation/tasks), [local-config](./roles/local-config/tasks) and [reverse-proxy](./roles/reverse-proxy/tasks)

* In ```user-creation``` will create users, set up group, copy public key and the user information 

* In ```local-config``` will change the VM IP address, change the hostname and disable ssh password authentication

* In ```reverse-proxy``` will create the project config file from this [template](./roles/reverse-proxy/templates/project.j2) then generated a basic authentication (if required) and finally reload the nginx config

## Quick Start

Install ansible with package manager
```bash
sudo apt install ansible
```

Install ansible with pip (highly recommmeded)
```
pip install --user ansible ansible-core
```

Change the information of the server from the [group_vars](./group_vars/all/)

## Running the playbook 

```bash
ansible-playbook setup.yml -vvv
```

## Know Limitations
* The playbook only works with one server because the nature of ansible when it comes to IP address is static. Futhermore, the template from the company has the same IP address across newly created VMs which is  ```172.16.200.12```. If the ticket happened to be 2 server then we will have to manually change the IP address of these servers and run the playbook if we want to run it simutanously, thus making this part of the playbook useless 
```
- name: Changing IP Address
  lineinfile:
    path: /etc/netplan/00-installer-config.yaml
    backrefs: yes
    regexp: '^(\s*)[#]?- {{ ansible_host }}(: )*' 
    line: '\1- {{ item.IpAdresss }}/24'
    state: "present"
  loop: "{{ server.info }}"
  register: ip_status

- name: Restart Netplan
  command: netplan apply
  async: 45
  poll: 0
  when: ip_status is changed
```
* The role ```software``` is only intended to use to install package from a package manager (i.e system packages) not packages that install on user environment 
