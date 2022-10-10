@@ -2,7 +2,7 @@
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "Boot2Docker for Windows"
#define MyAppVersion "1.7.1"
#define MyAppVersion "1.8.0"
#define MyAppPublisher "Docker Inc"
#define MyAppURL "https://docker.com"
#define MyAppContact "https://docs.docker.com"
  10  
bundle.sh
@@ -4,11 +4,11 @@ set -e
# Script to grab binaries that are going to be bundled with windows installer.
# Note to maintainers: Update versions used below with newer releases

boot2dockerIso=1.7.1
boot2dockerCli=1.7.1
docker=1.7.1
vbox=4.3.30
vboxRev=101610
boot2dockerIso=1.8.0
boot2dockerCli=1.8.0
docker=1.8.0
vbox=5.0.0
vboxRev=101573
msysGit=1.9.5-preview20150319

boot2dockerIsoSrc=boot2docker
