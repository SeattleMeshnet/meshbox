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

--------------------------------------
-- Active cjdns Nodes (UDPInterface) -
--------------------------------------
m:section(SimpleSection).template  = "cjdns_status"


nodemgmt = m:section(TypedSection, "node", translate("Enabled cjdns nodes (UDPInterface)"),
		     translate("First find the cjdns ip of your upstream node. \
				(Ask him/her if you can't find out) This is the \
				node you got connection credentials from."))
-- Add to CJDNS --
btn = nodemgmt:option(Button, "_btn", translate("Add to CJDNS"))


--------------------------------------
-- Active cjdns Nodes (ETHInterface) -
--------------------------------------

eth_nodemgmt = m:section(TypedSection, "enode", translate("Enabled cjdns nodes (ETHInterface)"),
		     translate("Auto-connect to other cjdns nodes on the same network."))
-- Add to CJDNS --
eth_ = eth_nodemgmt:option(Button, "_btn", translate("Add to CJDNS"))

--------------------------------------
-- IP TUNNEL MGMT
--------------------------------------
iptunnel_mgmt = m:section(TypedSection, "ipt_node", translate("System for tunneling IPv4 and ICANN IPv6 through cjdns."),
		     translate("This is using the cjdns switch layer as a VPN carrier."))

-- Add to CJDNS --ss
iptunnel_btn = iptunnel_mgmt:option(Button, "_btn", translate("Add to CJDNS"))

--[[
	8888888888                         888    d8b
	888                                888    Y8P
	888                                888
	8888888 888  888 88888b.   .d8888b 888888 888  .d88b.  88888b.  .d8888b
	888     888  888 888 "88b d88P"    888    888 d88""88b 888 "88b 88K
	888     888  888 888  888 888      888    888 888  888 888  888 "Y8888b.
	888     Y88b 888 888  888 Y88b.    Y88b.  888 Y88..88P 888  888      X88
	888      "Y88888 888  888  "Y8888P  "Y888 888  "Y88P"  888  888  88888P'
]]--

-- TODO: Function for cjdns service stop/start/restart/reload
-- function e.cfgvalue(self, section)
-- 	return luci.sys.init.enabled("cjdns") and self.enabled or self.disabled
-- end

-- function e.write(self, section, value)
-- 	if value == "1" then
-- 		luci.sys.call("/etc/init.d/cjdns enable >/dev/null")
-- 		luci.sys.call("/etc/init.d/cjdns start >/dev/null")
-- 	else
-- 		luci.sthunys.call("/etc/init.d/cjdns stop >/dev/null")
-- 		luci.sys.call("/etc/init.d/cjdns disable >/dev/null")
-- 	end
-- end




----------------------------
-- "Add to CJDNS" buttons --
----------------------------


function btn.write(self)

	-- TODO: Define this button
	-- What it does now: 	* writes out all nodes in uci.cjdns.node to /etc/cjdroute.conf
	-- What it should do: 	* inserts a specific row into cjdroutes "active" list of nodes
	-- Location: 		* Currently sits next to each row.. (see: what it should do)
	-- Location: 		* It could be unique button, represented like a global "add"


	local dkjson = require("dkjson") -- http://dkolf.de/src/dkjson-lua.fsl/home
	local uci    = require("uci")

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
			enabled  = cfg.enabled 		-- cjdns/nat66 (0, 1)
			bind 	 = cfg.beacon_interface -- eg; eth5
			beacon 	 = cfg.beacon_mode 	-- 0, 1, 2
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
			num     	= i 		--
			node    	= w 		-- cfg 035387
			password 	= x.password 	-- das brute
			name 		= x.name 	-- das name
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



--[[
	888     888 8888888b.  8888888b.       8888888          888                     .d888
	888     888 888  "Y88b 888   Y88b        888            888                    d88P"
	888     888 888    888 888    888        888            888                    888
	888     888 888    888 888   d88P        888   88888b.  888888 .d88b.  888d888 888888 8888b.   .d8888b .d88b.
	888     888 888    888 8888888P"         888   888 "88b 888   d8P  Y8b 888P"   888       "88b d88P"   d8P  Y8b
	888     888 888    888 888               888   888  888 888   88888888 888     888   .d888888 888     88888888
	Y88b. .d88P 888  .d88P 888               888   888  888 Y88b. Y8b.     888     888   888  888 Y88b.   Y8b.
	 "Y88888P"  8888888P"  888             8888888 888  888  "Y888 "Y8888  888     888   "Y888888  "Y8888P "Y8888
]]--

nodemgmt.anonymous = true
nodemgmt.addremove = true
nodemgmt.template  = "cbi/tblsection"


-- Name --
nodemgmt:option(Value, "name", translate("Name"))
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

--[[
	8888888888 88888888888 888    888      8888888          888                     .d888
	888            888     888    888        888            888                    d88P"
	888            888     888    888        888            888                    888
	8888888        888     8888888888        888   88888b.  888888 .d88b.  888d888 888888 8888b.   .d8888b .d88b.
	888            888     888    888        888   888 "88b 888   d8P  Y8b 888P"   888       "88b d88P"   d8P  Y8b
	888            888     888    888        888   888  888 888   88888888 888     888   .d888888 888     88888888
	888            888     888    888        888   888  888 Y88b. Y8b.     888     888   888  888 Y88b.   Y8b.
	8888888888     888     888    888      8888888 888  888  "Y888 "Y8888  888     888   "Y888888  "Y8888P "Y8888
]]--

eth_nodemgmt.anonymous = true
eth_nodemgmt.addremove = true
eth_nodemgmt.template  = "cbi/tblsection"

-- Nick Name   --
Enn = eth_nodemgmt:option(Value, "name", translate("Name"))
Enn.datatype    = "string" -- return ip4addr(val) or ip6addr(val)
Enn.placeholder = ""
-- MAC Address --
Eia = eth_nodemgmt:option(Value, "enode", translate("MAC Address"))
Eia.datatype    = "ipaddr" -- return ip4addr(val) or ip6addr(val)
Eia.placeholder = ""
-- Password --
Eac = eth_nodemgmt:option(Value, "password", translate("Password"))
Eac.datatype    = "string"
Eac.placeholder = ""
-- Public Key --
Eip = eth_nodemgmt:option(Value, "publicKey", translate("Public Key"))
Eip.datatype    = "string"
Eip.placeholder = ""



--[[
	8888888 8888888b.       88888888888                                  888
	  888   888   Y88b          888                                      888
	  888   888    888          888                                      888
	  888   888   d88P          888  888  888 88888b.  88888b.   .d88b.  888
	  888   8888888P"           888  888  888 888 "88b 888 "88b d8P  Y8b 888
	  888   888                 888  888  888 888  888 888  888 88888888 888
	  888   888                 888  Y88b 888 888  888 888  888 Y8b.     888
	8888888 888                 888   "Y88888 888  888 888  888  "Y8888  888

	// System for tunneling IPv4 and ICANN IPv6 through cjdns.
	// This is using the cjdns switch layer as a VPN carrier.
]]--

--[[
"router" : {    "ipTunnel":    {
    "allowedConnections": [
	//     "publicKey": "f64hfl7c4uxt6krmhPutTheRealAddressOfANodeHere7kfm5m0.k",
	//     "ip4Address": "192.168.1.24",
	//     "ip6Address": "2001:123:ab::10"
	"outgoingConnections": [
	// "6743gf5tw80ExampleExampleExampleExamplevlyb23zfnuzv0.k",
]]--

iptunnel_mgmt.anonymous = true
iptunnel_mgmt.addremove = true
iptunnel_mgmt.template  = "cbi/tblsection"

--  --
PFia = iptunnel_mgmt:option(Value, "name", translate("Name"))
PFia.datatype    = "ip4addr" -- return ip4addr(val) or ip6addr(val)
PFia.placeholder = ""

PFdr = iptunnel_mgmt:option(Value, "address", translate("IPv4 Address"))
PFdr.datatype    = "ip4addr" -- return ip4addr(val) or ip6addr(val)
PFdr.placeholder = ""

PSda = iptunnel_mgmt:option(Value, "6address", translate("IPv6 Address"))
PSda.datatype    = "ip6addr" -- return ip4addr(val) or ip6addr(val)
PSda.placeholder = ""

PKid = iptunnel_mgmt:option(Value, "publicKey", translate("Public Key"))
PKid.datatype    = "string" -- return ip4addr(val) or ip6addr(val)
PKid.placeholder = ""


--[[
       d8888          888    888                       d8b                   888    d8b
      d88888          888    888                       Y8P                   888    Y8P
     d88P888          888    888                                             888
    d88P 888 888  888 888888 88888b.   .d88b.  888d888 888 88888888  8888b.  888888 888  .d88b.  88888b.
   d88P  888 888  888 888    888 "88b d88""88b 888P"   888    d88P      "88b 888    888 d88""88b 888 "88b
  d88P   888 888  888 888    888  888 888  888 888     888   d88P   .d888888 888    888 888  888 888  888
 d8888888888 Y88b 888 Y88b.  888  888 Y88..88P 888     888  d88P    888  888 Y88b.  888 Y88..88P 888  888
d88P     888  "Y88888  "Y888 888  888  "Y88P"  888     888 88888888 "Y888888  "Y888 888  "Y88P"  888  888
]]--

passwd_mgmt = m:section(TypedSection, "anode", translate("Node Authorization Managment"),
		     translate("Anyone connecting and offering these passwords on connection will be allowed."))
passwd_mgmt.anonymous = true
passwd_mgmt.addremove = true


-- Add to CJDNS --
btn = passwd_mgmt:option(Button, "_btn", translate("Add to CJDNS"))
-- Name --
passwd_mgmt:option(Value, "name", translate("Affiliation Notes"))
-- Address --
ia = passwd_mgmt:option(Value, "address", translate("Address"))
ia.datatype    = "ipaddr" -- return ip4addr(val) or ip6addr(val)
ia.placeholder = ""

--[[
	 .d8888b.           888    888    d8b
	d88P  Y88b          888    888    Y8P
	Y88b.               888    888
	 "Y888b.    .d88b.  888888 888888 888 88888b.   .d88b.  .d8888b
	    "Y88b. d8P  Y8b 888    888    888 888 "88b d88P"88b 88K
	      "888 88888888 888    888    888 888  888 888  888 "Y8888b.
	Y88b  d88P Y8b.     Y88b.  Y88b.  888 888  888 Y88b 888      X88
	 "Y8888P"   "Y8888   "Y888  "Y888 888 888  888  "Y88888  88888P'
	                                                    888
	                                               Y8b d88P
	                                                "Y88P"
]]--

--[[
	TODO: Thinking that manual connect for ETHInterface is too big for this page
	TODO: Node(s) to connect to manually.
	ETHInterface -> connectTo -> "01:02:03:04:05:06":{"password":"a","publicKey":"b"}
]]--
s = m:section(NamedSection, "config", "Settings", translate("Settings"))
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
-- Deadlink detection
apw = s:taboption("general", Value, "deadlink_reset", translate("Reestablish link if inactivite"),
	    translate("Deadlink detection in seconds"))
apw.datatype = "string" -- resetAfterInactivitySeconds

--[[ Advanced Tab ]]--

-- IPv6
node6 = s:taboption("advanced", Value, "ipv6", translate("IPv6 Address"),
	    translate("IPv6 tunnel address"))
node6.datatype = "ip6addr"
-- Public Key
pbkey = s:taboption("advanced", Value, "publicKey", translate("Public Key"),
	    translate("Your Multipass to Hyperboria"))
pbkey.datatype = "string"
-- Private Key
prkey = s:taboption("advanced", Value, "privateKey", translate("Private Key"),
	    translate("Do not redistribute this key"))
prkey.datatype = "string"
-- Host IP
hip = s:taboption("advanced", Value, "bind_hostip", translate("Bound IP Address to cjdns"),
	    translate("Default 0.0.0.0 or ::1 for all interfaces"))
hip = "ipaddr"
-- Host Port
hpt = s:taboption("advanced", Value, "bind_hostport", translate("Bound port number for cjdns"),
	    translate("Choose a valid 0-65535 port number"))
hpt.datatype = "port"
-- Administrator password for cjdns
apw = s:taboption("advanced", Value, "admin_passwd", translate("Administrator password for cjdns"),
	    translate("Password for backend access to cjdadmin"))
apw.datatype = "string"

-- Administrator password for cjdns
Ppw = s:taboption("advanced", Value, "admin_passwd", translate("Administrator password for cjdns"),
	    translate("Password for backend access to cjdadmin"))
Ppw.datatype = "string"

--[[ Administrator Tab ]]--
-- Node Passwords
-- TODO * Allow multiple passwords here.
-- TODO * Generate multiple password here from --genconf
-- "authorizedPasswords" : [ {"password" : "dnpr72wqkhvk9h1p7762cuzd83lyf12"  }


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