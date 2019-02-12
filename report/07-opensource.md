# Contribution to open-source task

## ansible-role-389ds

As contribution to open-source, I decided to pick an outdated role, for installing LDAP 389-ds, from Ansible Galaxy which would be useful to implement in Project III. The role hadn't been updated for more than 18 months. [Pull request](https://github.com/CSCfi/ansible-role-389-ds/pull/2) is still pending as a proof of contribution to the project. The repository isn't maintained anymore so 
I decided to copy the existing role and re-wrote it to recent syntax, added functionality and tweaked it to be more up to date.

Together with Ismail El Kaddouri I added features to add users and OU's to the LDAP server too. Role was written based on previously scripted installation tasks performed by Ismail and I.

Link to the repository with the ansible role Ismail and I wrote: [ansible-role-389ds](https://github.com/LennertMertens/ansible-role-389ds)

I published the role on Ansible Galaxy as well! [lennertmertens.ansible_role_389ds](https://galaxy.ansible.com/lennertmertens/389ds)

## Bertvv/cheat-sheets

As second contribution I added SELinux commands to an EL7 cheat-sheet of bertvv. There was an issue on Github for the SELinux chapter in the cheat-sheet so I decided to complete it by adding useful SELinux commands. I forked the repository, added the requested commands and created a pull request. The pull request got accepted too!

- [Forked repository](https://github.com/LennertMertens/cheat-sheets)
- [Accepted pull request commit](https://github.com/bertvv/cheat-sheets/commit/fb993c27b7a9044f420d5fdf989d8e5a37cd12d4)

## ansible-role-dns

Created a role for adding DNS servers and domains to a given network-interface. The role configures the DNS server settings in the `/etc/sysconfig/network-scripts/ifcfg-*` files to make modifications persistent.

- Used in Project III and Enterprise Linux

Link to the repository with the ansible role: [ansible-role-dns](https://github.com/LennertMertens/ansible-role-dns).
The role got also published on Ansible Galaxy: [lennertmertens.ansible-role-dns](https://galaxy.ansible.com/lennertmertens/dns).



# Extra technology

## Ansible Vault for plain password encryption

On servers pu004 and pr011 passwords appear visible in the yaml configuration files, due to security risks it's interesting for encrypting these passwords in order to keep the passwords safe from users with negative intentions. Ansible-vault enables users to encrypt strings, doing this creates an ansible hash that can be pasted in the yaml files.

### Procedure:
## Encrypt the desired passwords
1. Add following line to the vagrant file: `ansible.ask_vault_pass = true`
```yml
# Provisioning configuration for Ansible (for Mac/Linux hosts).
  config.vm.provision ansible_mode do |ansible|
    ansible.playbook = host.key?('playbook') ?
        "ansible/#{host['playbook']}" :
        "ansible/site.yml"
    ansible.become = true
    ansible.compatibility_mode = '2.0'
    ansible.ask_vault_pass = true
```

2. Execute the following command in the terminal, replace password123 in the password that needs to be encrypted.

3. Ansible prompts you for a `New Vault password` in this environment password: `elnx` is used
```
$ ansible-vault encrypt_string password123
New Vault password: 
Confirm New Vault password: 
!vault |
          $ANSIBLE_VAULT;1.1;AES256
          33626364313662393666336265343761383866623836343366663466363436336434366435386235
          3132356635303362396165633666613265303265356664370a306338363764313539303435366333
          33356430313266306530613662376438373833636134393838633164343362363431306266373332
          3037396235666466640a363637653231333166363135623032643961666561616363623366386634
          3831
Encryption successful
```

4. Change all plain text passwords in `pu004.yml` and `pr011.yml` by repeating the process from above. 

### pu004
1. Start the server: `vagrant up pu004`
2. Ansible will promt you for the vault's password this time:
```
 pu004: Running ansible-playbook...
Vault password: 
```
3. Fill in the password earlier configured: `elnx` in our case
3. SSH to the server: `vagrant ssh pu004`
4. Run the tests in order to check if server is correctly configured: Passing!


### pr0011
1. Start the server: `vagrant up pr011`
2. Ansible will promt you for the vault's password this time:
```
 pu004: Running ansible-playbook...
Vault password: 
```
3. Fill in the password earlier configured: `elnx` in our case
3. SSH to the server: `vagrant ssh pr011`
4. Run the tests in order to check if server is correctly configured: Passing!
5. Connecting with the different users and their password works too! (if they have privileges to log in to the shell!)

### (Password for ansible vault: elnx)

## Sources
- [Ansible Vault](https://docs.ansible.com/ansible/2.4/vault.html)
- [Vagrant: Ansible Vault](https://www.vagrantup.com/docs/provisioning/ansible.html#ask_vault_pass)