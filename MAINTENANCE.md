@@ -21,6 +21,12 @@ by applying the following steps:
- "Name of the Sign Tool:" `ksign`
- "Command of the Sign Tool:" `"C:\Program Files (x86)\kSign\kSignCMD.exe" /f Z:\sven\src\docker\windows-installer\docker-code-signing.pfx /p d_get_from_core $p`

# Releasing a new version

Update the versions of the dependencies as well as Boot2Docker in `bundle.sh`.

Update `#define MyAppVersion` line in `Boot2Docker.iss`.

# Downloading bundle dependencies

Open a git bash window in this directory and run script:
@@ -30,9 +36,6 @@ Open a git bash window in this directory and run script:
This should be downloading dependencies with their correct versions to `bundle\`
folder where the Inno Setup Compiler can pick up from.

If you need to change the versions of the installed software, this is the correct
place to do it.

# Compiling the installer

After configuring, open `boot2docker.iss` with Inno Setup Compiler and hit
