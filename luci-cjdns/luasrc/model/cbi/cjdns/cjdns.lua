--[[
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>
Copyright 2008-2011 Jo-Philipp Wich <xm@subsignal.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

]]--


--  Project Meshnet  --
m = Map("cjdns", luci.util.pcdata(translate("Project Meshnet")),
	translate("please return the default message"))


-----------------------
-- Active Cjdns Nodes -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
m:section(SimpleSection).template  = "cjdns_status"

---------------------
-- Cjdns Node List --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
nodemgmt = m:section(TypedSection, "node", translate("Cjdns Node List"),
                     translate("First find the Cjdns ip of your upstream node. \
                                (Ask him/her if you can't find out) This is the \
                                node you got connection credentials from."))

nodemgmt.anonymous = true
nodemgmt.addremove = true
nodemgmt.template  = "cbi/tblsection"

-------------------------
-- Add to cjdns button --
-------------------------
btn = nodemgmt:option(Button, "_btn", translate("Add to CJDNS"))
function btn.write(self)


	dkjson = require("dkjson") -- http://dkolf.de/src/dkjson-lua.fsl/home
	uci=require("uci")

	local f = io.open("/etc/cjdroute.conf")

	local conf, pos, err = dkjson.decode(f:read("*a"), 1, nil) -- cbid.cjdns.cfg045e2e._btn



function getConfType(conf,type) --  Sophana
	local curs=uci.cursor()
	local ifce={}
	curs:foreach(conf,type,
				 function(s)
					ifce[s[".name"]]=s
				 end)
	return ifce
end




	luci.model.uci.cursor():foreach("cjdns", "cjdns",
		function(cfg)
			hostname = cfg.port
			-- timezone = cfg.address
			timezone = cfg.port
			bcnint 	 = cfg.beacon_interface
			beacon 	 = cfg.enable_beacons
			np 		 = cf
		end)

	-- x:set("cjdns","cfg04e10c","blah","blah")

local prio = getConfType("cjdns","node")
	-- Get Hostname, replace bind with it (testing)
		-- luci.model.uci.cursor():foreach("system", "system", function(s) hostname = s.hostname end)
		-- bind = uci:get("network", "lan", "ifname"), beacon = 35635, connectTo = {} 
		-- bind = hostname,

	conf.interfaces.ETHInterface = 
	{ 
		{ 
			beacon = beacon,
			bcnint = bcnint,
			connectTo = {}
		} 
	}

	

	conf.interfaces.UDPInterface =
	{
		{
			connectTo = prio
		}
	}

	-- HOLD --
	-------------------------
	-- Add peers to config --
	-------------------------
	-- local peerfile = io.open("/usr/share/presetpeers")
	-- if peerfile ~=	nill then
		-- local peers, peerspos, peerserr = dkjson.decode(peerfile:read("*a"), 1, nill)
		-- conf.interfaces.UDPInterface[1].connectTo = peers
	-- end

	f:close()

	-- local save = io.open("/tmp/cjdroute.conf", "w")
	local save = io.open("/etc/cjdroute.conf", "w")
	save:write( dkjson.encode (conf, { indent = true }))
	save:close()

end

-- Name --
nodemgmt:option(Value, "name", translate("Name"))
nodemgmt.placeholder = ""
nodemgmt.placeholder = goal

-- Address --
ia = nodemgmt:option(Value, "address", translate("Address"))
ia.datatype    = "ipaddr" -- return ip4addr(val) or ip6addr(val)
ia.placeholder = ""

-- TODO split on address and port for node-name (for each iteration of section/type )
-- Port --
ep = nodemgmt:option(Value, "port", translate("Port"))
ep.datatype    = "portrange"
ep.placeholder = ""

-- Public Key --
ip = nodemgmt:option(Value, "publicKey", translate("Public Key"))
ip.datatype    = "string"
ip.placeholder = ""

-- Password --
ac = nodemgmt:option(Value, "password", translate("Password"))
ac.datatype    = "string"
ac.placeholder = ""

-- TODO too big for 1 page now
-- Node(s) to connect to manually.
-- ETHInterface -> connectTo -> "01:02:03:04:05:06":{"password":"a","publicKey":"b"}


--------------------
-- Cjdns Settings --
-- -- -- -- -- -- --
s = m:section(NamedSection, "config", "Cjdns Settings", translate("Cjdns Settings"))
s.addremove = false

-- Tabs --
s:tab("general",  translate("General"))
s:tab("advanced", translate("Advanced"))
s:tab("admin",    translate("Administrator"))
s:tab("ezpaste",  translate("EZ-Paste Box"))

-----------------
-- General Tab --
-----------------

e = s:taboption("general", Flag, "enabled", translate("Enable Cjdns and NAT66 service"),
	translate("Toggles the start of both Cjdns and NAT66 services upon Boot"))
e.default  = 1
e.rmempty  = false

-- HOLD --
-- function e.cfgvalue(self, section)
-- 	return luci.sys.init.enabled("cjdns") and self.enabled or self.disabled
-- end

-- function e.write(self, section, value)
-- 	if value == "1" then
-- 		luci.sys.call("/etc/init.d/cjdns enable >/dev/null")
-- 		luci.sys.call("/etc/init.d/cjdns start >/dev/null")
-- 	else
-- 		luci.sys.call("/etc/init.d/cjdns stop >/dev/null")
-- 		luci.sys.call("/etc/init.d/cjdns disable >/dev/null")
-- 	end
-- end

-- Beacons --
bc = s:taboption("general", ListValue, "enable_beacons", translate("Enable Beacons"),
	              translate("Select the preferred Beacons mode for ETHInterface"))
bc:value(0, translate("0 -- Disabled."))
bc:value(1, translate("1 -- Accept Beacons, this will cause Cjdns to accept incoming \
                      Beacon messages and try connecting to the Sender."))
bc:value(2, translate("2 -- Accept and Send Beacons to LAN broadcast address which \
                      contain a One-time Pad secret password."))

-- Bcn Int --
bi = s:taboption("general", Value, "beacon_interface",
	             translate("Select the preferred Beacon Ethernet Interface"),
	             translate("Select the preferred Beacon Ethernet Interface"))
bi.datatype    = "string"
bi.placeholder = eth0

-- Logging --
s:taboption("general", Flag, "enable_stdlog", translate("Enable additional logging to logread"),
	translate("Puts extra debugging information into logread"))


------------------
-- Advanced Tab --
------------------

-- Public Key --
pbkey = s:taboption("advanced", Value, "cfg_publicKey", translate("Public Key"),
            translate("Your Multipass to Hyperboria"))
pbkey.datatype = "string"

-- Private Key --
prkey = s:taboption("advanced", Value, "cfg_prvkey", translate("Private Key"),
            translate("Do not redistribute this key"))
prkey.datatype = "string"

-- Host IP --
hip = s:taboption("advanced", Value, "cfg_hostip", translate("Bound IP Address to cjdns"),
            translate("Default 0.0.0.0 or ::1 for all interfaces"))
hip = "ipaddr"

-- Host Port --
hpt = s:taboption("advanced", Value, "cfg_hostport", translate("Bound port number for cjdns"),
            translate("Choose a valid 0-65535 port number"))
hpt.datatype = "port"

----------------
--> Admin Tab --
----------------

-- Admin Password --
apw = s:taboption("admin", Value, "adm_passwd", translate("Administrator password for cjdns"),
            translate(""))
apw.datatype = "string"

-- TODO Make more passwords here (support for more multiple passwords available)

-- Node Passwords --
-- TODO Make this a field during node creation...
  -- "authorizedPasswords" : [ {"password" : "dnpr72wqkhvk9h1p7762cuzd83lyf12"  }
  --       // More passwords should look like this.
  --       // {"password": "hh7y2y6s1chq4grf172wfqlz544ccpr"},
  --       // {"password": "4phn47d2b939mrlh9ndhq3wnr21zu4x"},
  --       // {"password": "64550khf36nzn55cbdlttfgsz078tn7"},

--------------------------------
-- Router Managment Node List --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
local router_mgmt = false
if router_mgmt then
rttrmgmt = m:section(TypedSection, "node", translate("Cjdns Router Managment List"),
                     translate("This page is responsible for the Router section"))

rttrmgmt.anonymous = true
rttrmgmt.addremove = true
rttrmgmt.template  = "cbi/tblsection"
end

-- TODO page is too big i think..
----------------------
--> Router Settings --
----------------------
--[[ "router" : {    "ipTunnel":
        {

            "allowedConnections":
            [
                // {
                //     "publicKey": "f64hfl7c4uxt6krmhPutTheRealAddressOfANodeHere7kfm5m0.k",
                //     "ip4Address": "192.168.1.24",
                //     "ip6Address": "2001:123:ab::10"
                // },

                // It's ok to only specify one address.
                // {
                //     "publicKey": "ydq8csdk8p8ThisIsJustAnExampleAddresstxuyqdf27hvn2z0.k",
                //     "ip4Address": "192.168.1.24",
                //     "ip6Address": "2001:123:ab::10"
                // }
            ],

            "outgoingConnections":
            [
                // Connect to one or more machines and ask them for IP addresses.
                // "6743gf5tw80ExampleExampleExampleExamplevlyb23zfnuzv0.k",
                // "pw9tfmr8pcrExampleExampleExampleExample8rhg1pgwpwf80.k",
                // "g91lxyxhq0kExampleExampleExampleExample6t0mknuhw75l0.k"
            ]
        }
    },
]]--

----------------------
--> Generate Config --
----------------------
-- Button to auto-generate EzCrypt URL with routers /etc/cjdroute.conf info would be nice.

-- x = require("uci").cursor()
-- lf.placeholder = x:get("network", "lan", "ifname")

----------------------
--> Easy Paste Node --
----------------------
ez = s:taboption("ezpaste", Value, "ezpaste",
	             translate("Node information should be relayed by \
                           an Encrypted Pastebin: EZCrypt https://ezcrypt.it/"))
ez.template	= "cbi/tvalue"
ez.rows 	= 5
ez.wrap 	= "off"

return m