# VM Setup Automation 

## Using Ansible to set up a VM when created 

The tasks are separated into different roles, including user-creation and local-config

* In user-creation will create users, set up group, copy public key, the information is read from the ```vars``` folder and inside is a JSON file format that contains all information about the user we want to create 

> Here is an example demo of the task

```yaml
# Debian
- block:
  - name: Creating User
    user:
      name: "{{ item.name }}"
      create_home: yes
      append: "{{ item.append }}"
      groups: "{{ item.group }}"
      shell: "{{ item.shell }}"
      password: "{{ item.password | password_hash('sha512') }}"
      state: present
    loop: "{{ SudoUserLists.users }}"

  - name: Creating ssh directory
    file:
      path: "{{ item.home }}/.ssh"
      state: directory
      mode: "700"
      owner: "{{ item.name }}"
      group: "{{ item.name }}"
    loop: "{{ SudoUserLists.users }}"

  - name: Adding user key
    copy:
      content: "{{ item.pubkey }}"
      dest: "/home/{{ item.name }}/.ssh/authorized_keys"
      mode: "600"
      owner: "{{ item.name }}"
      group: "{{ item.name }}"
    loop: "{{ SudoUserLists.users }}"
  when: ansible_facts['distribution'] == "Ubuntu"

# CentOS
- block: 
  - name: Creating User
    user:
      name: "{{ item.name }}"
      create_home: yes
      append: "{{ item.append }}"
      groups: "{{ item.group }}"
      shell: "{{ item.shell }}"
      password: "{{ item.password | password_hash('sha512') }}"
      state: present
    loop: "{{ WheelUserLists.users }}"

  - name: Creating ssh directory
    file:
      path: "{{ item.home }}/.ssh"
      state: directory
      mode: "700"
      owner: "{{ item.name }}"
      group: "{{ item.name }}"
    loop: "{{ WheelUserLists.users }}"

  - name: Adding user key
    copy:
      content: "{{ item.pubkey }}"
      dest: "/home/{{ item.name }}/.ssh/authorized_keys"
      mode: "600"
      owner: "{{ item.name }}"
      group: "{{ item.name }}"
    loop: "{{ WheelUserLists.users }}"
  when: ansible_facts['distribution'] == "CentOS"

```

* In local-config will change the VM IP address, change the hostname and disable ssh password authentication, all of this information are also read from ```vars``` folder with JSON file format 

> Here is an example demo of the task

```yaml

- name: Changing Hostname
  hostname: 
    name: "{{ item.hostname }}"
  loop: "{{ info.config }}"

# Debian
- block:
  - name: Changing IP Address
    lineinfile:
      path: /etc/netplan/00-installer-config.yaml
      backrefs: yes
      regexp: '^(\s*)[#]?- {{ ansible_host }}(: )*' 
      line: '\1- {{ item.IpAdresss }}'
      state: "present"
    loop: "{{ info.config }}"

  - name: Deleting extra ssh config line
    lineinfile:
      path: /etc/ssh/sshd_config
      regexp: "PasswordAuthentication yes"
      state: "absent"

  - name: Changing ssh config
    lineinfile:
      path: /etc/ssh/sshd_config
      regexp: "#PasswordAuthentication yes"
      line: "PasswordAuthentication no"
      state: "present"
  when: ansible_facts['distribution'] == "Ubuntu"

# CentOS
- block:
  - name: Changing IP Address
    replace:
      path: /etc/sysconfig/network-scripts/ifcfg-eth0
      regexp: "{{ ansible_host }}" 
      replace: "{{ item.IpAdresss }}"
      #state: "present"
    loop: "{{ info.config }}"

  - name: Deleting extra ssh config line
    lineinfile:
      path: /etc/ssh/sshd_config
      regexp: "PasswordAuthentication yes"
      state: "absent"

  - name: Changing ssh config
    lineinfile:
      path: /etc/ssh/sshd_config
      regexp: '#PasswordAuthentication yes'
      line: "PasswordAuthentication no"
      state: "present"  
  when: ansible_facts['distribution'] == "CentOS"


```

* Reverse-Proxy config can load the website config files in JSON format to populate all the config for each websites, playbook can create basic authentoication as an option for secure web server, and finally reload when there's changes or newly config file created