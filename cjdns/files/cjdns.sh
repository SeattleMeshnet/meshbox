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

START=50
STOP=85

CJDROUTE="/usr/sbin/cjdroute"
CONF="/etc/cjdroute.conf"
PID="$(pgrep -f $CJDROUTE)"

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
        echo "cjdns is not running"
        return 1
    else
	for k in $PID
	    do echo "cjdns (pid ${k}) terminated"
	    kill -9 ${k}
	done
	nat6 off
    fi
}

start()
{
    if [ ! -f $CONF ]; then
        logger -t cjdns "No file found at $CONF creating new one" 
        $CJDROUTE --genconf > /tmp/cjdns.tmp
        $CJDROUTE --cleanconf < /tmp/cjdns.tmp > $CONF
	rm /tmp/cjdns.tmp
        lua /usr/share/cjdroutesetup.lua
	sync
    fi

    if [ -z "$PID" ]; then
        logger -t cjdns "Starting cjdns"
        $CJDROUTE < $CONF
	nat6 on
        if [ $? -gt 0 ]; then
            echo "Failed to start cjdns"
            nat6 off
	    return 1
        fi
    else
        echo "cjdns is already running"
        return 1
    fi
}
