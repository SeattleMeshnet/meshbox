--[[
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>
Copyright 2008-2011 Jo-Philipp Wich <xm@subsignal.org>
Copyright 2013-2014 William Fleurant <igel@hyperboria.ca>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

]]--

--  Project Meshnet  --
m = Map("cjdns", luci.util.pcdata(translate("Project Meshnet")),
	translate("cjd's ideology that networks should be easy to set up, \
		   protocols should scale up smoothly, \
		   and security should be ubiquitous."))

------------------------
-- Active cjdns nodes --
------------------------
m:section(SimpleSection).template  = "cjdns/status"

---------------------------------------
-- Enabled cjdns nodes (UDPInterface) -
---------------------------------------
nodemgmt = m:section(TypedSection, "node", translate("Enabled cjdns nodes (UDPInterface)"),
		     translate("First find the cjdns ip of your upstream node. \
				(Ask him/her if you can't find out) This is the \
				node you got connection credentials from."))

---------------------------------------
-- Enabled cjdns nodes (ETHInterface) -
---------------------------------------
eth_nodemgmt = m:section(TypedSection, "enode", translate("Enabled cjdns nodes (ETHInterface)"),
		     translate("Auto-connect to other cjdns nodes on the same network."))

------------------------------------------------
-- Enabled cjdns iptunnels (allowed/outgoing) --
------------------------------------------------
iptunnel_mgmt = m:section(TypedSection, "ipt_node", translate("Enabled cjdns iptunnels (allowed/outgoing)"),
		     translate("This system for tunneling IPv4 and ICANN IPv6 through cjdns \
				 is using the cjdns switch layer as a VPN carrier."))


----------------------------------
-- Node Authorization Managment --
----------------------------------
passwd_mgmt = m:section(TypedSection, "node_auth_mgmt", translate("Node Authorization Managment"),
		     translate("Anyone connecting and offering these passwords on connection will be allowed."))
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

m.on_after_commit = function(self)
	os.execute("/usr/share/cjdns/cli.lua uci2conf")
	os.execute("/etc/init.d/cjdns restart")
end

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
-- if luci.theme=openwrt ? (enable) : l.theme=boot ? (disable)

-- Nick Name   --
Enn = eth_nodemgmt:option(Value, "name", translate("Name"))
Enn.datatype    = "string" -- return ip4addr(val) or ip6addr(val)
Enn.placeholder = ""
-- MAC Address --
Eia = eth_nodemgmt:option(Value, "enode", translate("MAC Address"))
Eia.datatype    = "macaddr" -- return ip4addr(val) or ip6addr(val)
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
]]--

iptunnel_mgmt.anonymous = true
iptunnel_mgmt.addremove = true
iptunnel_mgmt.template  = "cbi/tblsection"

PFia = iptunnel_mgmt:option(Value, "name", translate("Name"))
PFia.datatype    = "string" -- return ip4addr(val) or ip6addr(val)
PFia.placeholder = ""

PFdr = iptunnel_mgmt:option(Value, "address", translate("IPv4 Address"))
PFdr.datatype    = "ip4addr" -- return ip4addr(val) or ip6addr(val)
PFdr.placeholder = ""

PSda = iptunnel_mgmt:option(Value, "address_6", translate("IPv6 Address"))
PSda.datatype    = "ip6addr" -- return ip4addr(val) or ip6addr(val)
PSda.placeholder = ""

PKid = iptunnel_mgmt:option(Value, "publicKey", translate("Public Key"))
PKid.datatype    = "string" -- return ip4addr(val) or ip6addr(val)
PKid.placeholder = ""

PKbc = iptunnel_mgmt:option(ListValue, "iptflow", translate("Select either Allowed or Outgoing"))
PKbc:value("allowed", translate("Allowed"))
PKbc:value("outgoing", translate("Outgoing"))


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

-- TODO Put this into a tabbed section (double check if lists are permitted in tab sections)

passwd_mgmt.anonymous = true
passwd_mgmt.addremove = true
passwd_mgmt.template  = "cbi/tblsection"

-- Affiliated Password --
passwd_mgmt:option(Value, "name", translate("Affiliation Notes"))
-- Address --
ia = passwd_mgmt:option(Value, "password", translate("Password"))
ia.datatype    = "string" -- return ip4addr(val) or ip6addr(val)
ia.placeholder = "very strong password"

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

s = m:section(NamedSection, "cjdns", "Settings", translate("Settings"))
s.addremove = false

-- Tabs --
s:tab("general",  translate("General"))
s:tab("advanced", translate("Advanced"))
s:tab("admin",    translate("Administrator"))
s:tab("ezpaste",  translate("EZ-Paste Box"))

--[[ General Tab ]]--

-- Host IP
hip = s:taboption("general", Value, "bind_hostip", translate("IP Address bound to UDPInterface"),
	    translate("Default 0.0.0.0 or ::1 for all interfaces"))
hip = "ipaddr"
-- Host Port
hpt = s:taboption("general", Value, "bind_hostport", translate("Port number bound to UDPInterface"),
	    translate("Choose a valid 0-65535 port number"))
hpt.datatype = "port"
-- Beacon operations
bc = s:taboption("general", ListValue, "beacon_mode", translate("Enable Beacons"),
		      translate("Select the preferred Beacons mode for ETHInterface"))
bc:value(0, translate("0 -- Disabled."))
bc:value(1, translate("1 -- Accept Beacons, this will cause cjdns to accept incoming \
		      Beacon messages and try connecting to the Sender."))
bc:value(2, translate("2 -- Accept and Send Beacons to LAN broadcast address which \
		      contain a One-time Pad secret password."))
bc.datatype = "integer(range(0,2))"
-- Beacon Interface
bi = s:taboption("general", Value, "beacon_interface",
		     translate("Select the preferred Beacon Ethernet Interface"),
		     translate("Select the preferred Beacon Ethernet Interface"))
bi.datatype    = "string"
bi.placeholder = "eth0"

-- Logging -- Feature not yet ready/tested for serial/vpty relay + socat
--s:taboption("general", Flag, "logto_enable", translate("Enable additional logging to logread"),
--	translate("Puts extra debugging information into logread"))

-- Deadlink detection
apw = s:taboption("general", Value, "deadlink_reset", translate("Reestablish link if inactivite"),
	    translate("Deadlink detection in seconds"))
apw.datatype = "integer(range(0,2048))" -- resetAfterInactivitySeconds

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
-- Administrator password for cjdns Admin
apw = s:taboption("advanced", Value, "admin_pass", translate("Password for cjdns admin"),
	    translate("Password for backend access to cjdadmin"))
apw.datatype = "string"
-- Administrator IP address for Active cjdns nodes
aip = s:taboption("advanced", Value, "admin_bind", translate("IP Address bound to cjdns admin"),
	    translate("Default 127.0.0.1 or ::1 for all interfaces"))
aip = "ipaddr"
-- Administrator Host Port for Active cjdns nodes
apt = s:taboption("advanced", Value, "admin_port", translate("Port number bound to cjdns admin"),
	    translate("Choose a valid 0-65535 port number"))
apt.datatype = "port"



--[[ Administrator Tab ]]--

-- TODO * AutoGen all the passwords, better layout

--[[ Generate Config ]]--
-- /etc/cjdroute.conf would be pretty killer.. we
-- should keep log of peering details distributed
-- for the next step:

--[[ EZ-Paste Box ]]--
-- Button to auto-generate EzCrypt URL with peering info found in
-- Node information should be relayed by community
-- approved method: EZCrypt https://ezcrypt.it

ez = s:taboption("ezpaste", Value, "ezpaste",
		     translate("Node information should be relayed by \
				an Encrypted Pastebin: EZCrypt https://ezcrypt.it/"))
ez.template	= "cbi/tvalue"
ez.rows 	= 5
ez.wrap 	= "off"

return m
