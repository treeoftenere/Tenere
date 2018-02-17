NETWORK=10.200.1
for HOST in {2..254} ;do (ping $NETWORK.$HOST -c 1 >/dev/null && echo "\"$NETWORK.$HOST\"," &);done
