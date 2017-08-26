for i in {2..254} ;do (ping 192.168.1.$i -c 1 -w 5  >/dev/null && echo "\"192.168.1.$i\"," &);done
