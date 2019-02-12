# Enterprise Linux Lab Report: 00-server-setup

- Student name: Lennert Mertens
- Github repo: <https://github.com/HoGentTIN/elnx-1819-sme-LennertMertens>

Installing `bertvv.rh-base` role on server `pu004` meeting the defined requiremenets. This task involves getting familiar with Ansible and the Ansible-skeleton.

## Test plan

1. On the host system, go to the local working directory of the project repository
2. Execute `vagrant status`
    - There should be one VM, `pu004` with status `not created`. If the VM does exist, destroy it first with `vagrant destroy -f pu004`
3. Execute `vagrant up pu004`
    - The command should run without errors (exit status 0)
4. Log in on the server with `vagrant ssh pu004` and run the acceptance tests. They should succeed

    ```
    [vagrant@pu004 test]$ sudo /vagrant/test/runbats.sh
    Running test /vagrant/test/common.bats
    ✓ EPEL repository should be available
    ✓ Bash-completion should have been installed
    ✓ bind-utils should have been installed
    ✓ Git should have been installed
    ✓ Nano should have been installed
    ✓ Tree should have been installed
    ✓ Vim-enhanced should have been installed
    ✓ Wget should have been installed
    ✓ Admin user bert should exist
    ✓ Custom /etc/motd should be installed

    10 tests, 0 failures
    ```

    Any tests for the LAMP stack may fail, but this is not part of the current assignment.

5. Log off from the server and ssh to the VM as described below. You should **not** get a password prompt.

    ```
    $ ssh lennert@192.0.2.50
    Welcome to pu004.localdomain.
    enp0s3     : 10.0.2.15         fe80::a00:27ff:fe5c:6428/64
    enp0s8     : 192.0.2.50        fe80::a00:27ff:fecd:aeed/64

## Procedure/Documentation

#### 1. Getting familiar with Ansible
#### 2. Installing the preffered roll: `bertvv.rh-base`

```
$ ansible-galaxy -p ansible/roles install bertvv.rh-base
```
**Note:** All roles mudt be installed in `ansible/roles`

Another and faster possibility to isntall all roles defined in `ansible/site.yml`: 
```
~$ ./scripts/role-deps.sh
```
*Roles are ignored by Github, so don't modify anything in the rule. If a role needs to be tweaked, fork the role and maintain it there*


#### 3. Configuring `pu004` as described in assignment

- Firewall should be enabled and running
- SELinux should be set to 'Enforcing'
- Create an administrator user account for yourself. 
- You should be able to log into your servers without having to enter a password.
- Use the option to generate a custom /etc/motd file that shows network connection information after login.

These configurations are done in `/ansible/host_vars/pu004.yml` a file with specific configurations for `pu004`
``` yml
---
rhbase_firewall_allow_services:
  - http
  - https
rhbase_selinux_state: enforcing
rhbase_users:
  - name: lennert
    comment: 'Lennert Mertens'
    groups:
      - users
      - wheel
rhbase_motd: true
rhbase_ssh_user: lennert
rhbase_ssh_key: ssh-rsa AAAAB3NzaC1yc2EAA...

```

- The EPEL repository must be installed (Extra Packages for Enterprise Linux, a third-party package repository)
- The following packages must be installed on all servers
    - bash-completion
    - bind-utils
    - git
    - nano
    - tree
    - vim-enhanced
    - wget

These configurations are done in `/ansible/group_vars/all.yml` a file with specific configurations for `all` servers installing the role `rh-base`

``` yml
# Packages being installed by bertvv.rh-base role
rhbase_repositories: 
  - epel-release
rhbase_install_packages:
  - bash-completion
  - vim-enhanced
  - bind-utils
  - git
  - nano 
  - tree
  - wget
```

#### 4. Running the vm

```
$ vagrant up pu004
```

#### 5. Testing


## Test report

####  Run the acceptance tests
```
$ sudo /vagrant/tests/runbats.sh
```
### 04/10/2018: issues
- 2 tests failing
```
 ✓ SELinux should be set to 'Enforcing'
 ✓ Firewall should be enabled and running
 ✓ EPEL repository should be available
 ✓ Bash-completion should have been installed
 ✓ bind-utils should have been installed
 ✓ Git should have been installed
 ✓ Nano should have been installed
 ✓ Tree should have been installed
 ✓ Vim-enhanced should have been installed
 ✓ Wget should have been installed
 ✗ Admin user lennert should exist
   (in test file /vagrant/test/common.bats, line 53)
     `[ -n "$(groups ${admin_user} | grep wheel)" ]' failed
   lennert:x:1001:1001::/home/lennert:/bin/bash
 ✗ An SSH key should have been installed for lennert
   (in test file /vagrant/test/common.bats, line 58)
     `[ -f "${keyfile}" ]' failed
 ✓ Custom /etc/motd should have been installed
 13 tests, 2 failures
 ```

 Changes in configuration:
 ``` yml
# First version:
rhbase_users:
  - name: lennert
  - comment: 'Lennert Mertens'
  - groups: wheel
rhbase_ssh_key: 
  - ssh-rsa AAAAB3NzaC1yc2EAAAA...

 # Modified:
 rhbase_users:
  - name: lennert
    comment: 'Lennert Mertens'
    groups:
      - users
      - wheel
rhbase_ssh_user: lennert
rhbase_ssh_key: ssh-rsa AAAAB3NzaC1yc2EAAAA...
 ```

#### Connect via SSH without having to enter a password
```
Lennerts-MacBook-Pro: lennert$ ssh lennert@192.0.2.50
Welcome to pu004..
eth0       : 10.0.2.15         fe80::9e4:3fc1:1100:5a7/64  
eth1       : 192.0.2.50        fe80::a00:27ff:fe70:45df/64  
[lennert@pu004 ~]$ 
```

## Resources

- [Ansible Getting Started](https://docs.ansible.com/ansible/latest/user_guide/intro_getting_started.html)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Udemy Course](https://www.udemy.com/ansible-essentials-simplicity-in-automation/)
- [Syllabus Enterprise Linux](https://github.com/HoGentTIN/elnx-syllabus/)
- [bertvv.rh-base](https://github.com/bertvv/ansible-role-rh-base)
- [bertvv.ansible-skeleton](https://github.com/bertvv/ansible-skeleton)
