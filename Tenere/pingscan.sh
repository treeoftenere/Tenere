FILE=addresses.txt

echo collecing addresses and storing in file: $FILE
rm $FILE 2> /dev/null
for i in {2..254} ;do (ping 192.168.1.$i -c 1 >/dev/null && echo "192.168.1.$i" &) >> $FILE;done
echo got:
cat $FILE
echo ^^ there you have it.  Now run processing sketch.
