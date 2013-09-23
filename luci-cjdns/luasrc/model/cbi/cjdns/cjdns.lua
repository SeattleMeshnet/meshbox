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
-- Active cjdns Nodes -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
m:section(SimpleSection).template  = "cjdns_status"

---------------------
-- cjdns Node List --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
nodemgmt = m:section(TypedSection, "node", translate("cjdns Node List"),
                     translate("First find the cjdns ip of your upstream node. \
                                (Ask him/her if you can't find out) This is the \
                                node you got connection credentials from."))
nodemgmt.anonymous = true
nodemgmt.addremove = true
nodemgmt.template  = "cbi/tblsection"

-- TODO: Function for cjdns service stop/start/restart/reload
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

----------------------------
-- "Add to CJDNS" buttons --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

btn = nodemgmt:option(Button, "_btn", translate("Add to CJDNS"))
function btn.write(self)

	-- TODO: Define this button
	-- What it does now: 	* writes out all nodes in uci.cjdns.node to /etc/cjdroute.conf
	-- What it should do: 	* inserts a specific row into cjdroutes "active" list of nodes
	-- Location: 			* Currently sits next to each row.. (see: what it should do)
	-- Location: 			* It could be unique button, represented like a global "add"


	local dkjson = require("dkjson") -- http://dkolf.de/src/dkjson-lua.fsl/home
	local uci 	 = require("uci")

	local cjdroute = io.open("/etc/cjdroute.conf")
	local conf, pos, err = dkjson.decode(cjdroute:read("*a"), 1, nil) -- cbid.cjdns.cfg045e2e._btn

	-- http://luci.subsignal.org/api/luci/modules/luci.model.uci.html
	-- iterate with x:foreach to list all the elements of a given type
	function getConfType(conf,type) -- Sophana
		local curs=uci.cursor()
		local ifce={}
		curs:foreach(conf,type,
					 function(s)
						ifce[s[".name"]]=s
					 end)
		return ifce
	end

	-----------------------------
	-- interfaces.ETHInterface --
	-----------------------------
	luci.model.uci.cursor():foreach("cjdns", "cjdns",
		function(cfg)
			-- TODO  : cfg.logTo_
			logTo 	 = cfg.logto_enable 	-- conf.logging NOT DONE
			enabled  = cfg.enabled 			-- cjdns/nat66 (0, 1)
			bind 	 = cfg.beacon_interface -- eg; eth5
			beacon 	 = cfg.beacon_mode 		-- 0, 1, 2
		end)

	-- Stage the ETHInterface array
	conf.interfaces.ETHInterface = 
	{ 
		{ 
			beacon = beacon,
			bind   = bind,
			connectTo = {}
		} 
	}
	-----------------------------
	-- interfaces.UDPInterface --
	-----------------------------



	--[[
	-------------------------
	-- Add peers to config --
	-------------------------
	If there are 0 nodes:
		* create a new valid (but empty) section, or:
		  fill in the presetpeers eg:
			if action and (peerfile ~= nil); then
				local peerfile = io.open("/usr/share/presetpeers")
			    local peers, peerspos, peerserr = dkjson.decode(peerfile:read("*a"), 1, nill)
			    peers = conf.interfaces.UDPInterface[1].connectTo
			end
	]]--

	-- Right now, Just output getConfType() into connectTo{}
	local peers = getConfType("cjdns","node")

	-- BUG: FIX bind = cfg.bindip .. cfg.bindport
	local cfg_bugbind = "0.0.0.0:41343"

	-- Stage the UDPInterface array, presetpeers
	conf.interfaces.UDPInterface =
	{
		{
			bind 	  = cfg_bugbind,
			connectTo = peers
		}
	}

	-- Stage for /etc/cjdroute.conf
	for i = 1,#conf.interfaces.UDPInterface do

		local cjdstatus = {}
		local hpux = {}
		local udpif = conf.interfaces.UDPInterface[i]

		if (udpif == nil) then
			break
		end

		for w,x in pairs(udpif.connectTo) do
			num     	= i 			--
			node    	= w 			-- cfg 035387
			password 	= x.password 	-- das brute
			name 		= x.name 		-- das name
			publicKey 	= x.publicKey 	-- das key
			address 	= x.address 	-- das ip
			thing 		= w

			if node then
				-- Create subarrays for connectTo.


				-- BUG Need to use udpif.connectTo{} (UCI Is temporary and vaninty fix)
				-- BUG REPLACE: cfg035387 ("node" column) with host:port
				x 		= require("uci").cursor()
				address = x:get("cjdns",node,"address")
				port 	= x:get("cjdns",node,"port")

				if address and port then
					hp = address .. ":" .. port

					cjdstatus[#cjdstatus+1] = {} -- connectTo{node:port[#]{}}

					-- Stage new node:port[#]{var:val}
					hpux[hp] = { -- "1.2.3.4:1234:{}"
							name  	  = name,		-- name (could be nil)
							address   = address,	--
							port   	  = port,		--
							password  = password,	-- password
							publicKey = publicKey,	-- publickey.k
					}

					cjdstatus[#cjdstatus] = hpux
				end
			end
		end
			conf.interfaces.UDPInterface[i].connectTo = cjdstatus[#cjdstatus]
	end

	cjdroute:close()

	local save = io.open("/etc/cjdroute.conf", "w")
	save:write( dkjson.encode (conf, { indent = true }))
	save:close()

end -- btn.write

---------------------
-- cjdns Node List --
-- -- -- -- -- --  -- --  -- -- -- -- -- -- -- -- -- -- -- -- --

-- Name --
nodemgmt:option(Value, "name", translate("Name"))
nodemgmt.placeholder = ""
nodemgmt.placeholder = goal
-- Address --
ia = nodemgmt:option(Value, "address", translate("Address"))
ia.datatype    = "ipaddr" -- return ip4addr(val) or ip6addr(val)
ia.placeholder = ""
-- Port --
ep = nodemgmt:option(Value, "port", translate("Port"))
ep.datatype    = "portrange"
ep.placeholder = ""
-- Password --
ac = nodemgmt:option(Value, "password", translate("Password"))
ac.datatype    = "string"
ac.placeholder = ""
-- Public Key --
ip = nodemgmt:option(Value, "publicKey", translate("Public Key"))
ip.datatype    = "string"
ip.placeholder = ""

-- TODO: Thinking that manual connect for ETHInterface is too big for this page
-- NOTE: "This page" is NOT bootstrap theme!

-- TODO: Node(s) to connect to manually.
-- ETHInterface -> connectTo -> "01:02:03:04:05:06":{"password":"a","publicKey":"b"}

--------------------
-- cjdns Settings --
-- -- -- -- -- -- --
s = m:section(NamedSection, "config", "cjdns Settings", translate("cjdns Settings"))
s.addremove = false

-- Tabs --
s:tab("general",  translate("General"))
s:tab("advanced", translate("Advanced"))
s:tab("admin",    translate("Administrator"))
s:tab("ezpaste",  translate("EZ-Paste Box"))

--[[ General Tab ]]--

-- Enable/Disable cjdns & nat66
e = s:taboption("general", Flag, "enabled", translate("Enable cjdns and NAT66 service"),
	translate("Toggles the start of both cjdns and NAT66 services upon Boot"))
e.default  = 1
e.rmempty  = false

-- Beacon operations
bc = s:taboption("general", ListValue, "beacon_mode", translate("Enable Beacons"),
	              translate("Select the preferred Beacons mode for ETHInterface"))
bc:value(0, translate("0 -- Disabled."))
bc:value(1, translate("1 -- Accept Beacons, this will cause cjdns to accept incoming \
                      Beacon messages and try connecting to the Sender."))
bc:value(2, translate("2 -- Accept and Send Beacons to LAN broadcast address which \
                      contain a One-time Pad secret password."))
-- Beacon Interface
bi = s:taboption("general", Value, "beacon_interface",
	             translate("Select the preferred Beacon Ethernet Interface"),
	             translate("Select the preferred Beacon Ethernet Interface"))
bi.datatype    = "string"
bi.placeholder = eth0

-- Logging
s:taboption("general", Flag, "logto_enable", translate("Enable additional logging to logread"),
	translate("Puts extra debugging information into logread"))

--[[ Advanced Tab ]]--

-- Public Key
pbkey = s:taboption("advanced", Value, "cfg_publicKey", translate("Public Key"),
            translate("Your Multipass to Hyperboria"))
pbkey.datatype = "string"
-- Private Key
prkey = s:taboption("advanced", Value, "cfg_prvkey", translate("Private Key"),
            translate("Do not redistribute this key"))
prkey.datatype = "string"
-- Host IP
hip = s:taboption("advanced", Value, "cfg_hostip", translate("Bound IP Address to cjdns"),
            translate("Default 0.0.0.0 or ::1 for all interfaces"))
hip = "ipaddr"
-- Host Port
hpt = s:taboption("advanced", Value, "cfg_hostport", translate("Bound port number for cjdns"),
            translate("Choose a valid 0-65535 port number"))
hpt.datatype = "port"

--[[ Administrator Tab ]]--

-- Administrator password for cjdns
apw = s:taboption("admin", Value, "adm_passwd", translate("Administrator password for cjdns"),
            translate(""))
apw.datatype = "string"

-- Node Passwords
-- TODO * Allow multiple passwords here.
-- TODO * Generate multiple password here from --genconf
-- "authorizedPasswords" : [ {"password" : "dnpr72wqkhvk9h1p7762cuzd83lyf12"  }

-- Router Managment will return as a leaf of services/cjdns/routermgmt --

--[[
"router" : {    "ipTunnel":    {
    "allowedConnections": [
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
        // } ],
	"outgoingConnections": [
        // Connect to one or more machines and ask them for IP addresses.
        // "6743gf5tw80ExampleExampleExampleExamplevlyb23zfnuzv0.k",
        // "pw9tfmr8pcrExampleExampleExampleExample8rhg1pgwpwf80.k",
        // "g91lxyxhq0kExampleExampleExampleExample6t0mknuhw75l0.k"
        ]    } },
]]--

--[[ Generate Config ]]--
-- Button to auto-generate EzCrypt URL with peering info found in
-- /etc/cjdroute.conf would be pretty killer.. we
-- should keep log of peering details distributed

--[[ EZ-Paste Box ]]--
-- Node information should be relayed by community
-- approved method: EZCrypt https://ezcrypt.it
ez = s:taboption("ezpaste", Value, "ezpaste",
	             translate("Node information should be relayed by \
                           an Encrypted Pastebin: EZCrypt https://ezcrypt.it/"))
ez.template	= "cbi/tvalue"
ez.rows 	= 5
ez.wrap 	= "off"

return m