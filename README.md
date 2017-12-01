
[![CI Status](http://img.shields.io/travis/Shashikant86/iOS-Dev-Ansible.svg?style=flat)](https://travis-ci.org/Shashikant86/iOS-Dev-Ansible)

# Xcode Server: Ansible provisioning for iOS Continuous Integration
=========

This role can be used to setup iOS Continuous Integration Service on macOS using Apple's own CI server a.k.a Xcode Server.
This role also can be used for the setting up local development environment for the iOS Developer. It has all the tools required for the iOS Developers like Xcode, Swift Fastlane, Carthage, Cocoapods and lot's of homebrew packages, however you can have full control to configure your own environment with variables.  Xcode installation needs pre-downloaded XIP file

Requirements
------------

* macOS High Seirra
* Xcode 9 +

Xcode version before 9 are not supported with this role


### Xcode Setup Requirements

There are couple of ways this role can install Xcode, you can pick one that is suitable for you  

* Xcode XIP in `files` directory of playbook

You should place a `xip` in the `files/` directory of your playbook or place the XIP file inside $HOME directory `~/Xcode_9.1.xip`
Mention the `xcode_src` variable with version of Xcode you wish to install


```
xcode_src: Xcode_9.1.xip
```

What's in this role:
--------------
This role comes with following softwares packages to provision iOS Continuous Integration Server.

* Xcode 9+ Installation
* Xcode Server Service
* macOS defaults : Controls defaults and Software Updates
* Homebrew : Package Manager for macOS to install packages like cartahge or cask applications (optional)
* RVM and customised Ruby versions for Pre-installed Gems like bundler, Fastlane, Cocoapods, Xcpretty (optional)

You can customise your own playbook to override defaults and create your own playbook.

Role Variables:
----------------

This role has lot of variables which can be used to configure your own playbook. Please refer `defaults/main.yml` for list of all variables. **You can override `defaults/main.yml` variables to configure your own**. The main variables that you should change are


```
xcode_src: Xcode_{your_version}.xip

xcode_server_user: {your_xcodeserver_user}
ansible_ssh_user: {your_ansible_ssh_user}

```

How to use this Role:
--------------

Imagine, you have fresh Mac with fresh macOS installed. You can setup all your Xcode Server for CI by creating Playbook for this role. You can setup config variables as per your need.

Assuming you have installed Ansible, we can download the role by running command

           $ $ ansible-galaxy install Shashikant86.XcodeServer

Now that, we have to create our own playbook for this role by setting variables,  We can use `defaults/main.tml` file [here](https://github.com/Shashikant86/iOS-Dev-Ansible/blob/master/defaults/main.yml). The example playbook looks like this


Example Playbook
----------------

Make a new directory called `XcodeServer` also create `XcodeServer/files` directoty and put Xcode XIP inside `files` directory.

               $ mkdir xcode_server
               $ mkdir XcodeServer/files
               $ touch xcs_playbook.yml

Create `xcs_playbook.yml` like this inside the 'XcodeServer` directory with following content to run playbook locally. You can replace `localhost` with different hosts.  

```
---
- hosts: localhost
  connection: local

  vars:
    clean_xcode: yes
    clean_rvm: yes
    clean_homebrew: yes

    configure_xcode: yes
    configure_xcodeserver: yes
    configure_macos_defaults: yes
    configure_ruby_rvm: yes
    configure_homebrew: yes

    xcode_src: Xcode_9.1.xip

    xcode_server_user: shashi
    ansible_ssh_user: shashi

    ruby_version: 2.4.0
    rubygems_packages_to_install:
      - bundler
      - xcpretty

    macos_sleep_options:
      - systemsetup -setsleep Never
      - systemsetup -setharddisksleep Never
      - systemsetup -setcomputersleep Never

    macos_animation_options:
      - defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
      - defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
      - defaults write com.apple.dock expose-animation-duration -int 0
      - defaults write com.apple.dock launchanim -bool false

    macos_software_autoupdates:
      - softwareupdate --schedule off


    homebrew_use_brewfile: true
    homebrew_brewfile_dir: '~'
    homebrew_repo: https://github.com/Homebrew/brew
    homebrew_prefix: /usr/local
    homebrew_install_path: "{{ homebrew_prefix }}/Homebrew"
    homebrew_brew_bin_path: /usr/local/bin
    homebrew_upgrade_all_packages: no


    homebrew_installed_packages:
      - autoconf
      - bash-completion
      - git
      - carthage
      - gpg
      - boost
      - cmake
      - ssh-copy-id
      - openssl
      - wget
      - curl

    homebrew_taps:
      - homebrew/core
      - caskroom/cask
      - homebrew/binary
      - homebrew/dupes
      - homebrew/versions

    homebrew_cask_apps:
      - postman

  roles:
    - Shashikant86.XcodeServer


```

Change `ansible_ssh_user` and `xcode_server_user` with your username and Feel free to set variables as per your need. Now execute this playbook

      $ ansible-playbook xcs_playbook.yml

Watch your mac Mini servers getting setup for iOS Continuous Integration.

Setting up Continuous Intrgration with Travis
------------

We can test this role on TravisCI by disabling the Xcode config as TravisCI has it's own Xcode images. We can test all other things on TravisCI. You can see the TravisCI config in the `.travis.yml` and playbook/config inside the `tests` directory. You can see TravisCI output [here](https://travis-ci.org/Shashikant86/iOS-Dev-Ansible/builds/203170430)


Dependencies
------------

None



License
-------

MIT

Author Information
------------------

Shashikant Jagtap
