#!/bin/sh /etc/rc.common
#
# You may redistribute this program and/or modify it under the terms of
# the GNU General Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

START=90
STOP=85

CJDROUTE="/usr/sbin/cjdroute"
CONF="/etc/cjdroute.conf"
PID="$(pgrep -f $CJDROUTE)"
CJDNS_ENABLED="$(uci get cjdns.cjdns.enabled)"
if [ x${CJDNS_ENABLED} == x"1" ]
	then CJDNS_SERVICE="ENABLED"
	else CJDNS_SERVICE="DISABLED"
fi

nat6()
{
	[ "$1" == "on" ] \
		&& H="A" \
		|| H="D"

	ip6tables -t nat    -${H} POSTROUTING -o tun0 -j MASQUERADE
	ip6tables -t filter -${H} FORWARD -i tun0 -o br-lan -m state --state RELATED,ESTABLISHED -j ACCEPT
	ip6tables -t filter -${H} FORWARD -i eth1 -o br-lan -j ACCEPT

}
stop()
{
	if [ -z "$PID" ]; then
		logger "cjdns is not running"
		return 0
	else
		for k in $PID
			do logger "cjdns (pid ${k}) terminated"
			kill -9 ${k} 2>/dev/null
		done
		nat6 off
	fi
}

start()
{
	if [ ! -f $CONF ]; then
		logger -t cjdns "No file found at $CONF -- generating new config then applying /etc/config/cjdns"
		$CJDROUTE --genconf > /tmp/cjdns.tmp
		$CJDROUTE --cleanconf < /tmp/cjdns.tmp > $CONF
		rm /tmp/cjdns.tmp
		lua /usr/share/uci_to_cjdroute.lua
		# Preset Peers and Beacon Interface -- Anticipating duplicate entries, check required.
		# lua /usr/share/cjdroutesetup.lua
		sync
	fi

	if [ -z "$PID" ]; then
		logger -t cjdns "Starting cjdns"
		$CJDROUTE < $CONF
		nat6 on
		if [ $? -gt 0 ]; then
			logger "Failed to start cjdns"
			nat6 off
			return 1
		fi
	else
		logger "cjdns is already running"
		return 1
	fi
}

reconfigure()
{
	mv /etc/cjdroute.conf /tmp/cjdroute.conf.old

	logger -t cjdns "Generating new cjdns configuration"
	cjdroute --genconf > /tmp/cjdroute.conf.new
	cjdroute --cleanconf < /tmp/cjdroute.conf.new \
		> /etc/cjdroute.conf

	logger -t cjdns "Installing to UCI"
	sh -x /usr/share/cjdns_jsonpath.sh 2>&1 | grep uci \
	    | sed "s/+ uci set cjdns.cjdns.//"  | sort     \
	    | logger -t cjdns \
		&& logger -t cjdns "cjduci Installation: OK" \
		|| logger -y cjdns "cjduci Installation: Please Check /etc/config/cjdns"

	logger -t cjdns "Restarting cjdns"
	lua /usr/share/uci_to_cjdroute.lua
}
restart()
{
	/etc/init.d/cjdns stop
	/etc/init.d/cjdns start
}


## main

[ x"$1" == x"reconfigure" ] && reconfigure \
	&& logger "Reconfigure Complete"
