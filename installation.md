@@ -1,13 +1,14 @@
Install Inno Setup 5 non-unicode: http://www.jrsoftware.org/isdl.php (`isetup-5.x.x-unicode.exe`).

Install the `docker-code-signing.pfx` certificate; you will need the password
from `core`.
Install `kSignCMD`: http://codesigning.ksoftware.net/ (click "Download kSign" and then "FREE DOWNLOAD" or "Click Here to Download kSign", which will likely be a link to http://cdn1.ksoftware.net/ksign_installer.exe)

Install [Inno Setup 5 non-unicode](http://www.jrsoftware.org/isdl.php).
Install the `docker-code-signing.pfx` certificate somewhere (the instructions below assume `Z:\sven\src\docker\windows-installer\docker-code-signing.pfx`); you will need the password (`d_get_from_core` below).

Install `ksign_installer`
Open `Boot2Docker.iss` in the Inno Setup Compiler.  It has a few constants at the top that are important to make note of (especially `MyAppVersion` and the path variables `b2dISO`, `b2dCLI`, `msysGit`, `virtualBoxMsi`, and `virtualBoxCommon`).

Then follow the [ksign and Inno Setup](http://blog.ksoftware.net/2011/07/how-to-automate-code-signing-with-innosetup-and-ksign/) instructions so the resulting installer is signed.
- call the signing tool `ksign`
- cmd: `"C:\Program Files (x86)\kSign\kSignCMD.exe" /f Z:\sven\src\docker\windows-installer\docker-code-signing.pfx /p d_get_from_core $p`
Then follow the [ksign and Inno Setup](http://blog.ksoftware.net/2011/07/how-to-automate-code-signing-with-innosetup-and-ksign/) instructions so the resulting installer is signed:
- "Tools" > "Configure Sign Tools" > "Add"
- Name of the Sign Tool: `ksign`
- Command of the Sign Tool: `"C:\Program Files (x86)\kSign\kSignCMD.exe" /f Z:\sven\src\docker\windows-installer\docker-code-signing.pfx /p d_get_from_core $p`

Then hit 'Build'. The results will be in the `Output` dir.
  10  
README.md
@@ -4,12 +4,12 @@ Installation [instructions](http://docs.docker.io/installation/windows/) availab

## What is included:

- [msys-git 1.9.0](http://msysgit.github.io/) for tools like `OpenSSH` and `BASH`
- [VirtualBox 4.3.12](https://www.virtualbox.org)
- [Boot2Docker-cli management tool 1.2.0](https://github.com/boot2docker/boot2docker-cli)
- [Boot2Docker ISO 1.2.0](https://github.com/boot2docker/boot2docker)
- [msys-git 1.9.4](http://msysgit.github.io/) for tools like `OpenSSH` and `BASH`
- [VirtualBox 4.3.18](https://www.virtualbox.org)
- [Boot2Docker-cli management tool 1.3.0](https://github.com/boot2docker/boot2docker-cli)
- [Boot2Docker ISO 1.3.0](https://github.com/boot2docker/boot2docker)

(the ISO contains Docker 1.2.0 - unfortunately we don't have a windows Docker client yet)
(the ISO contains Docker 1.3.0 - unfortunately we don't have a native Windows Docker client yet)

## Why InnoSetup

 19  
delete.sh
@@ -1,14 +1,15 @@
#!sh
#!/bin/bash
set -e

# clear the MSYS MOTD
clear
# simplify by adding the program dir to the path
B2DPATH=$(dirname $0)
set PATH=%PATH%;$B2DPATH

echo "stopping..."
boot2docker.exe stop
echo "deleting..."
boot2docker.exe delete
cd "$(dirname "$BASH_SOURCE")"

( set -x; ./boot2docker.exe stop ) || true

( set -x; ./boot2docker.exe delete; rm -rf "$HOME/.boot2docker" ) || true

echo
echo "[Hit a key to exit]"
echo '[Press any key to exit]'
read
 414  
modpath.iss
@@ -1,207 +1,207 @@
// ----------------------------------------------------------------------------
//
// Inno Setup Ver:	5.4.2
// Script Version:	1.4.2
// Author:			Jared Breland <jbreland@legroom.net>
// Homepage:		http://www.legroom.net/software
// License:			GNU Lesser General Public License (LGPL), version 3
//						http://www.gnu.org/licenses/lgpl.html
//
// Script Function:
//	Allow modification of environmental path directly from Inno Setup installers
//
// Instructions:
//	Copy modpath.iss to the same directory as your setup script
//
//	Add this statement to your [Setup] section
//		ChangesEnvironment=true
//
//	Add this statement to your [Tasks] section
//	You can change the Description or Flags
//	You can change the Name, but it must match the ModPathName setting below
//		Name: modifypath; Description: &Add application directory to your environmental path; Flags: unchecked
//
//	Add the following to the end of your [Code] section
//	ModPathName defines the name of the task defined above
//	ModPathType defines whether the 'user' or 'system' path will be modified;
//		this will default to user if anything other than system is set
//	setArrayLength must specify the total number of dirs to be added
//	Result[0] contains first directory, Result[1] contains second, etc.
//		const
//			ModPathName = 'modifypath';
//			ModPathType = 'user';
//
//		function ModPathDir(): TArrayOfString;
//		begin
//			setArrayLength(Result, 1);
//			Result[0] := ExpandConstant('{app}');
//		end;
//		#include "modpath.iss"
// ----------------------------------------------------------------------------

procedure ModPath();
var
	oldpath:	String;
	newpath:	String;
	updatepath:	Boolean;
	pathArr:	TArrayOfString;
	aExecFile:	String;
	aExecArr:	TArrayOfString;
	i, d:		Integer;
	pathdir:	TArrayOfString;
	regroot:	Integer;
	regpath:	String;

begin
	// Get constants from main script and adjust behavior accordingly
	// ModPathType MUST be 'system' or 'user'; force 'user' if invalid
	if ModPathType = 'system' then begin
		regroot := HKEY_LOCAL_MACHINE;
		regpath := 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment';
	end else begin
		regroot := HKEY_CURRENT_USER;
		regpath := 'Environment';
	end;

	// Get array of new directories and act on each individually
	pathdir := ModPathDir();
	for d := 0 to GetArrayLength(pathdir)-1 do begin
		updatepath := true;

		// Modify WinNT path
		if UsingWinNT() = true then begin

			// Get current path, split into an array
			RegQueryStringValue(regroot, regpath, 'Path', oldpath);
			oldpath := oldpath + ';';
			i := 0;

			while (Pos(';', oldpath) > 0) do begin
				SetArrayLength(pathArr, i+1);
				pathArr[i] := Copy(oldpath, 0, Pos(';', oldpath)-1);
				oldpath := Copy(oldpath, Pos(';', oldpath)+1, Length(oldpath));
				i := i + 1;

				// Check if current directory matches app dir
				if pathdir[d] = pathArr[i-1] then begin
					// if uninstalling, remove dir from path
					if IsUninstaller() = true then begin
						continue;
					// if installing, flag that dir already exists in path
					end else begin
						updatepath := false;
					end;
				end;

				// Add current directory to new path
				if i = 1 then begin
					newpath := pathArr[i-1];
				end else begin
					newpath := newpath + ';' + pathArr[i-1];
				end;
			end;

			// Append app dir to path if not already included
			if (IsUninstaller() = false) AND (updatepath = true) then
				newpath := newpath + ';' + pathdir[d];

			// Write new path
			RegWriteStringValue(regroot, regpath, 'Path', newpath);

		// Modify Win9x path
		end else begin

			// Convert to shortened dirname
			pathdir[d] := GetShortName(pathdir[d]);

			// If autoexec.bat exists, check if app dir already exists in path
			aExecFile := 'C:\AUTOEXEC.BAT';
			if FileExists(aExecFile) then begin
				LoadStringsFromFile(aExecFile, aExecArr);
				for i := 0 to GetArrayLength(aExecArr)-1 do begin
					if IsUninstaller() = false then begin
						// If app dir already exists while installing, skip add
						if (Pos(pathdir[d], aExecArr[i]) > 0) then
							updatepath := false;
							break;
					end else begin
						// If app dir exists and = what we originally set, then delete at uninstall
						if aExecArr[i] = 'SET PATH=%PATH%;' + pathdir[d] then
							aExecArr[i] := '';
					end;
				end;
			end;

			// If app dir not found, or autoexec.bat didn't exist, then (create and) append to current path
			if (IsUninstaller() = false) AND (updatepath = true) then begin
				SaveStringToFile(aExecFile, #13#10 + 'SET PATH=%PATH%;' + pathdir[d], True);
			// If uninstalling, write the full autoexec out
			end else begin
				SaveStringsToFile(aExecFile, aExecArr, False);
			end;
		end;
	end;
end;
// Split a string into an array using passed delimeter
procedure MPExplode(var Dest: TArrayOfString; Text: String; Separator: String);
var
	i: Integer;
begin
	i := 0;
	repeat
		SetArrayLength(Dest, i+1);
		if Pos(Separator,Text) > 0 then	begin
			Dest[i] := Copy(Text, 1, Pos(Separator, Text)-1);
			Text := Copy(Text, Pos(Separator,Text) + Length(Separator), Length(Text));
			i := i + 1;
		end else begin
			 Dest[i] := Text;
			 Text := '';
		end;
	until Length(Text)=0;
end;
procedure CurStepChanged(CurStep: TSetupStep);
var
	taskname:	String;
begin
	taskname := ModPathName;
	if CurStep = ssPostInstall then
		if IsTaskSelected(taskname) then
			ModPath();
end;
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
	aSelectedTasks:	TArrayOfString;
	i:				Integer;
	taskname:		String;
	regpath:		String;
	regstring:		String;
	appid:			String;
begin
	// only run during actual uninstall
	if CurUninstallStep = usUninstall then begin
		// get list of selected tasks saved in registry at install time
		appid := '{#emit SetupSetting("AppId")}';
		if appid = '' then appid := '{#emit SetupSetting("AppName")}';
		regpath := ExpandConstant('Software\Microsoft\Windows\CurrentVersion\Uninstall\'+appid+'_is1');
		RegQueryStringValue(HKLM, regpath, 'Inno Setup: Selected Tasks', regstring);
		if regstring = '' then RegQueryStringValue(HKCU, regpath, 'Inno Setup: Selected Tasks', regstring);
		// check each task; if matches modpath taskname, trigger patch removal
		if regstring <> '' then begin
			taskname := ModPathName;
			MPExplode(aSelectedTasks, regstring, ',');
			if GetArrayLength(aSelectedTasks) > 0 then begin
				for i := 0 to GetArrayLength(aSelectedTasks)-1 do begin
					if comparetext(aSelectedTasks[i], taskname) = 0 then
						ModPath();
				end;
			end;
		end;
	end;
end;
// ----------------------------------------------------------------------------
//
// Inno Setup Ver:	5.4.2
// Script Version:	1.4.2
// Author:			Jared Breland <jbreland@legroom.net>
// Homepage:		http://www.legroom.net/software
// License:			GNU Lesser General Public License (LGPL), version 3
//						http://www.gnu.org/licenses/lgpl.html
//
// Script Function:
//	Allow modification of environmental path directly from Inno Setup installers
//
// Instructions:
//	Copy modpath.iss to the same directory as your setup script
//
//	Add this statement to your [Setup] section
//		ChangesEnvironment=true
//
//	Add this statement to your [Tasks] section
//	You can change the Description or Flags
//	You can change the Name, but it must match the ModPathName setting below
//		Name: modifypath; Description: &Add application directory to your environmental path; Flags: unchecked
//
//	Add the following to the end of your [Code] section
//	ModPathName defines the name of the task defined above
//	ModPathType defines whether the 'user' or 'system' path will be modified;
//		this will default to user if anything other than system is set
//	setArrayLength must specify the total number of dirs to be added
//	Result[0] contains first directory, Result[1] contains second, etc.
//		const
//			ModPathName = 'modifypath';
//			ModPathType = 'user';
//
//		function ModPathDir(): TArrayOfString;
//		begin
//			setArrayLength(Result, 1);
//			Result[0] := ExpandConstant('{app}');
//		end;
//		#include "modpath.iss"
// ----------------------------------------------------------------------------

procedure ModPath();
var
	oldpath:	String;
	newpath:	String;
	updatepath:	Boolean;
	pathArr:	TArrayOfString;
	aExecFile:	String;
	aExecArr:	TArrayOfString;
	i, d:		Integer;
	pathdir:	TArrayOfString;
	regroot:	Integer;
	regpath:	String;

begin
	// Get constants from main script and adjust behavior accordingly
	// ModPathType MUST be 'system' or 'user'; force 'user' if invalid
	if ModPathType = 'system' then begin
		regroot := HKEY_LOCAL_MACHINE;
		regpath := 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment';
	end else begin
		regroot := HKEY_CURRENT_USER;
		regpath := 'Environment';
	end;

	// Get array of new directories and act on each individually
	pathdir := ModPathDir();
	for d := 0 to GetArrayLength(pathdir)-1 do begin
		updatepath := true;

		// Modify WinNT path
		if UsingWinNT() = true then begin

			// Get current path, split into an array
			RegQueryStringValue(regroot, regpath, 'Path', oldpath);
			oldpath := oldpath + ';';
			i := 0;

			while (Pos(';', oldpath) > 0) do begin
				SetArrayLength(pathArr, i+1);
				pathArr[i] := Copy(oldpath, 0, Pos(';', oldpath)-1);
				oldpath := Copy(oldpath, Pos(';', oldpath)+1, Length(oldpath));
				i := i + 1;

				// Check if current directory matches app dir
				if pathdir[d] = pathArr[i-1] then begin
					// if uninstalling, remove dir from path
					if IsUninstaller() = true then begin
						continue;
					// if installing, flag that dir already exists in path
					end else begin
						updatepath := false;
					end;
				end;

				// Add current directory to new path
				if i = 1 then begin
					newpath := pathArr[i-1];
				end else begin
					newpath := newpath + ';' + pathArr[i-1];
				end;
			end;

			// Append app dir to path if not already included
			if (IsUninstaller() = false) AND (updatepath = true) then
				newpath := newpath + ';' + pathdir[d];

			// Write new path
			RegWriteStringValue(regroot, regpath, 'Path', newpath);

		// Modify Win9x path
		end else begin

			// Convert to shortened dirname
			pathdir[d] := GetShortName(pathdir[d]);

			// If autoexec.bat exists, check if app dir already exists in path
			aExecFile := 'C:\AUTOEXEC.BAT';
			if FileExists(aExecFile) then begin
				LoadStringsFromFile(aExecFile, aExecArr);
				for i := 0 to GetArrayLength(aExecArr)-1 do begin
					if IsUninstaller() = false then begin
						// If app dir already exists while installing, skip add
						if (Pos(pathdir[d], aExecArr[i]) > 0) then
							updatepath := false;
							break;
					end else begin
						// If app dir exists and = what we originally set, then delete at uninstall
						if aExecArr[i] = 'SET PATH=%PATH%;' + pathdir[d] then
							aExecArr[i] := '';
					end;
				end;
			end;

			// If app dir not found, or autoexec.bat didn't exist, then (create and) append to current path
			if (IsUninstaller() = false) AND (updatepath = true) then begin
				SaveStringToFile(aExecFile, #13#10 + 'SET PATH=%PATH%;' + pathdir[d], True);
			// If uninstalling, write the full autoexec out
			end else begin
				SaveStringsToFile(aExecFile, aExecArr, False);
			end;
		end;
	end;
end;
// Split a string into an array using passed delimeter
procedure MPExplode(var Dest: TArrayOfString; Text: String; Separator: String);
var
	i: Integer;
begin
	i := 0;
	repeat
		SetArrayLength(Dest, i+1);
		if Pos(Separator,Text) > 0 then	begin
			Dest[i] := Copy(Text, 1, Pos(Separator, Text)-1);
			Text := Copy(Text, Pos(Separator,Text) + Length(Separator), Length(Text));
			i := i + 1;
		end else begin
			 Dest[i] := Text;
			 Text := '';
		end;
	until Length(Text)=0;
end;
procedure CurStepChanged(CurStep: TSetupStep);
var
	taskname:	String;
begin
	taskname := ModPathName;
	if CurStep = ssPostInstall then
		if IsTaskSelected(taskname) then
			ModPath();
end;
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
	aSelectedTasks:	TArrayOfString;
	i:				Integer;
	taskname:		String;
	regpath:		String;
	regstring:		String;
	appid:			String;
begin
	// only run during actual uninstall
	if CurUninstallStep = usUninstall then begin
		// get list of selected tasks saved in registry at install time
		appid := '{#emit SetupSetting("AppId")}';
		if appid = '' then appid := '{#emit SetupSetting("AppName")}';
		regpath := ExpandConstant('Software\Microsoft\Windows\CurrentVersion\Uninstall\'+appid+'_is1');
		RegQueryStringValue(HKLM, regpath, 'Inno Setup: Selected Tasks', regstring);
		if regstring = '' then RegQueryStringValue(HKCU, regpath, 'Inno Setup: Selected Tasks', regstring);
		// check each task; if matches modpath taskname, trigger patch removal
		if regstring <> '' then begin
			taskname := ModPathName;
			MPExplode(aSelectedTasks, regstring, ',');
			if GetArrayLength(aSelectedTasks) > 0 then begin
				for i := 0 to GetArrayLength(aSelectedTasks)-1 do begin
					if comparetext(aSelectedTasks[i], taskname) = 0 then
						ModPath();
				end;
			end;
		end;
	end;
end;
 42  
start.sh
@@ -1,29 +1,31 @@
#!/bin/bash.exe
#!/bin/bash
set -e

# clear the MSYS MOTD
clear
# convert backslash paths to forward slash (yes, really, sometimes you get either)
B2DPATH=${0//\\/\//}
# remove the script-name
B2DPATH=${B2DPATH%/*}
# convert any C:/ into /c/ as MSYS needs this form
B2DPATH=$(echo $B2DPATH | sed 's/^\([A-Z]\):/\/\L\1/')
# simplify by adding the program dir to the path
PATH="$B2DPATH:$PATH"

ISO="$USERPROFILE/.boot2docker/boot2docker.iso"
cd "$(dirname "$BASH_SOURCE")"

ISO="$HOME/.boot2docker/boot2docker.iso"

if [ ! -e "$ISO" ]; then
	echo "copying initial boot2docker.iso (run 'boot2docker.exe download' to update"
	mkdir -p "$USERPROFILE/.boot2docker"
	cp "$B2DPATH/boot2docker.iso" "$ISO"
	echo 'copying initial boot2docker.iso (run "boot2docker.exe download" to update)'
	mkdir -p "$(dirname "$ISO")"
	cp ./boot2docker.iso "$ISO"
fi

echo "initializing..."
boot2docker.exe init
echo "starting..."
boot2docker.exe start
echo "connecting..."
boot2docker.exe ssh
echo 'initializing...'
./boot2docker.exe init
echo

echo 'starting...'
./boot2docker.exe start
echo

echo 'connecting...'
./boot2docker.exe ssh
echo

echo
echo "[Hit a key to exit]"
echo '[Press any key to exit]'
read
