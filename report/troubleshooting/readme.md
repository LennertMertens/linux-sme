# Troubleshooting Guide: Bottom-up Approach

This directory contains al steps you have to proceed through to properly troubleshoot a Linux system.

## Bottom-up Approach
Layer | Protocols | Keywords
:---- | :-------- | :-------
Application | HTTP, DNS, SMB, FTP, ... | 
Transport | TCP, UDP | sockets, ports, numbers
Internet | IP, ICMP | routing, IP address
Network Acces | Ethernet | switch, MAC adddress
Physical |  | cables

## Table of contents

* [Network Acces Layer](network-acces-layer.md)
* [Internet Layer](internet-layer.md)
* [Transport Layer](transport-layer.md)
* [Application Layer](application-layer.md)
* [SELinux](selinux.md)

## Tips
* Modify one thing at a time
* Verify the effect of modifications
* Make sure you can go a step back. Back-up the original config files
* Know the system and the network
* Read the error messages! (in log files) 
* Google and stack exchange is your friend

## Common Error messages
* No route to host
  * Internet layer
  * Problem with IP configuration

* Connection refused
  * Transoport layer
  * Service not started

* Unable to resolve host
  * Internet-/application layer
  * DNS server not available

* Error 404 not found
  * Application layer
  * URL wrong, fault in apache config


### Sources:
* [Troubleshooting network services in Linux](https://bertvv.github.io/linux-network-troubleshooting/)
* [Demo slides](https://hogenttin.github.io/elnx-syllabus/troubleshooting/#/title-slide)
* [Screencast Linux Troubleshooting](https://www.youtube.com/watch?v=ciXpmDwJKOM)
