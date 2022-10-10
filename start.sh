Mention boot2docker ssh in start.sh
Signed-off-by: Arnaud Porterie <arnaud.porterie@docker.com>
 master (#94)
 v1.8.0 
…
 v1.6.0
Arnaud Porterie committed on Apr 14, 2015 
1 parent 7739ffc commit 3e06e5e09185b4eef65e3fba66ec502f4f645b92
Showing 1 changed file with 2 additions and 0 deletions.
  2  
start.sh
@@ -31,5 +31,7 @@ echo 'setting environment variables ...'
eval "$(./boot2docker.exe shellinit 2>/dev/null | sed  's,\\,\\\\,g')"
echo

echo 'You can now use `docker` directly, or `boot2docker ssh` to log into the VM.'

cd
exec "$BASH" --login -i
