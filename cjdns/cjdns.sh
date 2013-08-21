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

# path to the cjdns source tree, no trailing slash
if [ -z "$CJDPATH" ]; then CJDPATH=`dirname $0`; fi

# full path to the cjdroute binary
if [ -z "$CJDROUTE" ]; then CJDROUTE="/usr/sbin/cjdroute"; fi

# full path to the configuration file
if [ -z "$CONF" ]; then CONF="/etc/cjdroute.conf"; fi

# path to the log file.
if [ -z "$LOGTO" ]; then LOGTO="/dev/null"; fi


START=25
STOP=85

load_pid()
{
    PID=$(pgrep -f $CJDROUTE)
}

load_pid

stop()
{
    if [ -z "$PID" ]; then
        echo "cjdns is not running"
        return 1
    else
        kill $PID &> /dev/null
        while [ -n "$(pgrep -d " " -f "$CJDROUTE")" ]; do
            echo "* Waiting for cjdns to shut down..."
            sleep 1;
        done
        if [ $? -gt 0 ]; then return 1; fi
    fi
}

start()
{
    if [ ! -f $CONF ]; then
        logger -t cjdns "No file found at $CONF creating new one" 
        $CJDROUTE --genconf > /tmp/cjdns.tmp
        $CJDROUTE --cleanconf < /tmp/cjdns.tmp > $CONF
        rm /tmp/cjdns.tmp
    fi
    if [ -z "$PID" ]; then
        logger -t cjdns "Starting cjdns"
        $CJDROUTE < $CONF
        if [ $? -gt 0 ]; then
            echo "Failed to start cjdns"
            return 1
        fi
    else
        echo "cjdns is already running"
        return 1
    fi
}

status()
{
    echo -n "* cjdns is "
    if [ -z "$PID" ]; then
        echo "not running"
        exit 1
    else
        echo "running"
        exit 0
    fi
}
