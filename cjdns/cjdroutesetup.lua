dkjson = require "dkjson" -- http://dkolf.de/src/dkjson-lua.fsl/home

local f = io.open("/etc/cjdroute.conf")

local conf, pos, err = dkjson.decode(f:read("*a"), 1, nil)

conf.interfaces.ETHInterface = { { bind = "eth0", beacon = 2, connectTo = {} } }

local peerfile = io.open("/usr/share/presetpeers")
if peerfile ~=	nill then
    local peers, peerspos, peerserr = dkjson.decode(peerfile:read("*a"), 1, nill)
    conf.interfaces.UDPInterface[1].connectTo = peers
end

f:close()

local save = io.open("/etc/cjdroute.conf", "w")
save:write( dkjson.encode (conf, { indent = true }))
save:close()
