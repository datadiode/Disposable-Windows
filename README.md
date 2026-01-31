[![StandWithUkraine](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/badges/StandWithUkraine.svg)](https://github.com/vshymanskyy/StandWithUkraine/blob/main/docs/README.md)

# Disposable-Windows

This project contains a vagrant file analogous to https://github.com/datadiode/Disposable-PepperMiXy but for Windows 10/11.

## Prerequisites

You'll need to have the following ready before you can use this:

- [VirtualBox](https://www.virtualbox.org/) installed and working
- [Vagrant](https://www.vagrantup.com/) installed and working 
- [PuTTY](https://putty.software/) installed and working 

Following an urge to explain the unobvious, good old PuTTY comes into play to avoid messing with WinRM.

Common VM lifecycle
```
#start vm
vagrant up [ Windows-10 | Windows-11 ]

#login
vagrant ssh [ Windows-10 | Windows-11 ]

#stop the vm
vagrant halt [ Windows-10 | Windows-11 ]

#when you want to start with a clean install
vagrant destroy [ Windows-10 | Windows-11 ]
vagrant up [ Windows-10 | Windows-11 ]
```
