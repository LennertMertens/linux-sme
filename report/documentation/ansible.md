# Introduction to ansible: notes and commands

- Automation platform
- Agentless
- +450 modules included

## How ansible works

- **Playbooks:** Tasks are executed sequentially, invokes Ansible modules (.yml)
- **Modules:** Tools in the toolkit, contain code for executing different actions
- **Inventory:** Consists of hosts and groups, variables

## Ad-hoc commands

- Quick checks that don't need to be saved for later

| Task | Command |
| :--- | :------ |
| `$ ansible all -m ping` | Check all my inventory hosts are ready to be managed by Ansible |
| `$ ansible web -m command -a "uptime` | Run the uptime commamnd on all hosts in the web group |
| `$ ansible localhost -m setup` | Collect and display the discovered for the localhost |

## Ansible playbooks

**Types of variables:**
- file: A directory should exist
- yum: A package should be installed
- service: A service should be running
- template: Render a config file from a template
- get_url: Fetch an archive file from a URL
- git: Clone a source code repository

### Tasks and handlers

- **Tasks:** Run sequantially and execute the defined task
- **Handlers** Are triggered when notified
```
tasks:
  - name: add cache dir
    file:
      path: /opt/cache
      state: directory

  - name: install nginx
    yum:
      name: nginx
      state: latest
    notify: restart ngnix       #Callss the handler task

handlers:
  - name: restart nginx
    service:
      name: nginx
      state: restarted
```

### Plays & playbooks

<dl>
  <dt>Plays</dt>
  <dd>Ordered sets of tasks to execute against hosts selections from your inventory.</dd>
  <dt>Playbook</dt>
  <dd>A file containing one or more plays.</dd>
</dl>

Playbook example: 
```
---
- name: install and start httpd
  hosts: web
  vars:
    http_port: 80
    max_clients: 200
  remote_user: root


  tasks
  - name: install httpd
    yum: pkg=httpd state=latest
  - name: write the apache config file
    template: src=/srv/httpd.j2 dest=/etc/httpd.conf
  - name: start httpd
    service: name=httpd state=started
```


**NOTE:** site.yml is most of the time the overall playbook 


