# Disposable Windows
# Repo: https://github.com/datadiode/Disposable-Windows
# Copyright (c) datadiode
# SPDX-License-Identifier: MIT
############################################################

# -*- mode: ruby -*-
# vi: set ft=ruby :
 
############################################################
# VM and Guest Settings - Review and Customize
############################################################

# BOX_PATH: map creatable boxes to base box paths
BOX_PATH =
{
    "Windows-7" => "datadiode/w7sbash",
    "Windows-9" => "datadiode/w9sbash",
    "Windows-10" => "datadiode/w10sbash",
    "Windows-11" => "datadiode/w11sbash"
}

# BOX_UPDATE: set to true to check for base box updates 
BOX_UPDATE = false

# VM_MEMORY: specify the amount of memory to allocate to the VM
#VM_MEMORY = "8192"
VM_MEMORY = "4096"
#VM_MEMORY = "2048"

# VM_CPUS: specify the number of CPU cores to allocate to the VM
VM_CPUS = "2"

# SHELL_ENV: environment to pass to shell provisioners
SHELL_ENV =
{
    # Keyboard language
    "KEYBOARD_LANGUAGE" => "00000407"
}

############################################################
# DO NOT ALTER BELOW HERE UNLESS YOU FEEL LIKE SO
############################################################

# If no propriatary payload is provided, create an empty one
FileUtils.touch 'scripts/setup.pp'

SHELL_ENV.each_key do |key|
  override = ENV["VAGRANT_SHELL_ENV_" + key]
  if override
    SHELL_ENV[key] = override
  end
end

Vagrant.configure("2") do |config|

  name = ARGV[1] ? ARGV[1] : BOX_PATH.keys[0]

  config.vm.define name, primary: true do |instance|

    instance.vm.box = BOX_PATH[name.split(".")[0]]
    instance.vm.box_check_update = BOX_UPDATE
    instance.vm.guest = :windows
    instance.vm.boot_timeout = 1800
    instance.vm.synced_folder '.', '/vagrant', disabled: true
    instance.vm.communicator = "ssh"
    instance.ssh.username = "vagrant"
    instance.ssh.password = "vagrant"
    instance.ssh.insert_key = false

    instance.vm.provider "VirtualBox" do |vbox|
      vbox.gui = true
      vbox.name = name
      vbox.memory = VM_MEMORY
      vbox.cpus = VM_CPUS
    end

    # It seems Vagrant wants to speak WinRM, therefore resort to pscp/plink
    instance.trigger.after [:up, :provision] do |trigger|
      trigger.ruby do |env,machine|
        hostkey = nil
        loop do 
          hostkey = %x(plink -batch -ssh vagrant@127.0.0.1 -P 2222 2>&1)[/\S+:\S+/,0]
          break if hostkey
          puts "failed to figure hostkey, trying again"
        end 
        envment = SHELL_ENV.map {|h| h.join '=' }.join ' '
        puts "hostkey = #{hostkey}"
        puts %x(pscp -pwfile pwfile.txt -hostkey #{hostkey} -r -P 2222 files scripts vagrant@127.0.0.1:C:/)
        puts "envment = #{envment}"
        puts %x(plink -pwfile pwfile.txt -batch -ssh vagrant@127.0.0.1 -P 2222 -hostkey #{hostkey} bash.exe -c #{envment} C:/scripts/setup.sh)
      end
    end
  end
end
