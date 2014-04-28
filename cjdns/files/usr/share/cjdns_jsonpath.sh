#!/bin/sh
# Purpose: put cjdroute.conf fields into uci
# deps: jow openwrt program jsonpath 
js=$(which jsonpath) 	# /usr/bin/jsonpath
c="/etc/cjdroute.conf"

#uci options
opts=""
# uci section
n1="cjdns.cjdns"

# future 
#n2="cjdns.node"
#n3="cjdns.enode"
#n4="cjdns.other"

# Sanity

for x in $js $c
	do if [ -f ${x} ]; then continue ; fi
	logger -t cjdns "Critical error: ${x} not found (See: $(basename $0))"
	exit 1
done


# Cherry pick

#cjdns idx/val
n="\
logto_enable=logging.logTo \
beacon_interface=interfaces.ETHInterface[0].bind \
beacon_mode=interfaces.ETHInterface[0].beacon \
deadlink_reset=resetAfterInactivitySeconds \
ipv6=ipv6 \
publicKey=publicKey \
privateKey=privateKey \
bind_hostport=interfaces.UDPInterface[0].bind \
bind_hostip=interfaces.UDPInterface[0].bind \
admin_pass=admin.password \
admin_port=admin.bind \
admin_bind=admin.bind"

for obj in $n; do
	key=$( echo $obj | cut -d= -f1 )
	val=$( echo $obj | cut -d= -f2 )
	cjs=$($js -i $c -e $.${val})
	if [ x"bind_hostport" == x"$key" ] \
	|| [ x"admin_port"    == x"$key" ]
		then index=2
	elif 
	   [ x"admin_bind"  == x"$key" ] \
	|| [ x"bind_hostip" == x"$key" ] 
		then index=1
	else
		uci $opts set $n1.$key=$($js -i $c -e $.${val})
		continue
	fi
	# host:ip split
	val=$( echo $cjs | cut -d: -f${index} )
	uci set $opts $n1.$key=$val
done

uci commit cjdns
sync

