# SELinux

## Sources
- [SELinux troubleshooting](https://hogenttin.github.io/elnx-syllabus/troubleshooting/#/selinux-troubleshooting)
- [Cheat-sheet](../cheat-sheets/selinux.md)

# Cheat sheet SELinux

### SELinux modes:
<dl>
  <dt>Disabled</dt>
  <dd>SELinux isn't working. Strongly disadviced.</dt>
  <dt>Enforcing</dt>
  <dd>SELinux opertates normally, enforcing the loaded security policy on the entire system. (Recommended)</dt>
  <dt>Permissive</dt>
  <dd>SELinux acts as if it's enforcing the loaded security policy, including labeling objects and emitting acces denial entries in the logs, but it does not actually deny any operations.</dd>
</dl>

### Labeling
- Format: 
  - `user:role:type:level(optinal)`
  - We really care about the type

### Type enforcement
- Type enforcement is the part of the policy that says, for instance, "a process running with the label httpd_t can have read acces to a file labeled httpd_config_t"

## What does it means if I get an SELinux error
- Labeling is wrong?
- Ploicy needs to be tweaked?
- There could be a bug in the policy
- You have been broken into

## What are booleans?
- Off/on settings for SELinux
- Location of active booleans:
  - `/etc/targeted/modules/active/booleans.local`

## Check /var/log/messages !!!
- `sudo cat /var/log/audit/audit.log`

## Where are contexts stored?
- restorecon uses information from `/etc/selinux/targeted/contexts/files/file_contexts` to determine what a file directory's context should be.

## Commands
| Command | Purpose |
| :------ | :------ |
| `setenforce 1`| Change to enforcing mode |
| `setenforce 0`| Change to permissive mode |
| `getenforce`| View the current SELinux mode  |
| `semanage permissive -a httpd_t`| Set individual domains to permissive mode while the system runs enforcing mode |
| `ls -Z file1`| View SELinux content of files and directories |
| `semanage login -l`| View a list of mappings between SELinux and Linux user accounts |
| `ps -eZ`| View SELinux context for processes |
| `id -Z`| View SELinux context associated with your user |
| `getsebool -a`| See all the booleans |
| `setsebool [boolean] 0`| Turn off the boolean |
| `setsebool [boolean] 1`| Turn on the boolean |
| `setsebool -P [boolean] [0|1]`| Make the boolean permanent |
| `chcon -t httpd_sys_content_t /var/www/html/index.html`| Change the SELinux context for the desired folder |
| `restorecon -vR /var/www/html/`| Fix the whole /var/www/html folder in the shortest way |
| `ls -Z /var/www/html/test.php`| Watch the SELinux type for a certain file |



### Example: changing the file context for all folders unde /foo
```bash
semanage fcontext -a -t httpd_sys_content_t "/foo(/.*)?"
# Or copy the context of one folder to another:
semanage fcontext -a -e /var/www/ /foo/
# Afterwards run:
restorecon -vR /foo/
```
## If SELinux was disabled, set it in permissive mode (NOT Enforcing!)
- Touch a file in the root of the filesystem: `touch /.autorelabel`
- Reboot
