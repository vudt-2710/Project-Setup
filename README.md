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