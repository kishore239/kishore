Deprecated

Docker
Deprecated
This project (the boot2docker Windows Installer) is officially deprecated in favor of the new Docker Toolbox.

windows-installer
Installation instructions available on the Docker documentation site.

What is included:
msys-git for tools like OpenSSH and BASH
VirtualBox
Boot2Docker-cli management tool
Boot2Docker ISO
Docker Client for Windows
Why Inno Setup?
I’ve chosen to make a simple installer using Inno Setup because that is what the msysGit installer is built with.

(It also happens that I’ve used Inno Setup before, so I can make something faster.)

Making a simple Wix for the Boot2Docker-cli should be simple, and this can then be used in this all-in-one installer too.

Maintenance
See MAINTENANCE.md for instructions on how to update, bundle and compile the Boot2Docker Windows Installer.
# windows-installer

Installation [instructions](https://docs.docker.com/installation/windows/) available on the Docker documentation site.
