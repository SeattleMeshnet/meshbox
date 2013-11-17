dkjson = require("dkjson") -- http://dkolf.de/src/dkjson-lua.fsl/home
uci = require("uci").cursor()

local f = io.open("/etc/cjdroute.conf")

local conf, pos, err = dkjson.decode(f:read("*a"), 1, nil)

mbifc = uci:get("cjdns", "config", "beacon_interface")
lnifc = uci:get("network", "lan", "ifname")

if     (mbifc ~= nil) then      -- prefer meshbox interface
        bcifc = mbifc
elseif (lnifc ~= nil) then      -- if not set, use "lan" interface
        bcifc = lnifc
else                            -- failsafe is lo
        bcifc = "lo"
end

conf.interfaces.ETHInterface = { { bind = bcifc, beacon = 2, connectTo = {} } }

local peerfile = io.open("/usr/share/presetpeers")
if (peerfile ~= nil) then
    local peers, peerspos, peerserr = dkjson.decode(peerfile:read("*a"), 1, nill)
    conf.interfaces.UDPInterface[1].connectTo = peers
end

f:close()

local save = io.open("/etc/cjdroute.conf", "w")
save:write( dkjson.encode (conf, { indent = true }))
save:close()
