--[[
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>
Copyright 2008-2011 Jo-Philipp Wich <xm@subsignal.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id: cjdns.lua 9570 2012-12-25 02:45:42Z jow $
]]--

m = Map("cjdns", luci.util.pcdata(translate("Project Meshnet")),
	translate("cjd's ideology that networks should be easy to set up, \
				protocols should scale up smoothly, \
					and security should be ubiquitous."))

m:section(SimpleSection).template  = "cjdns_status"

---------------------
-- Cjdns Node List --
---------------------
nodemgmt = m:section(TypedSection, "node", translate("Cjdns Node List"),
	translate("First find the Cjdns ip of your upstream node. \
		(Ask him/her if you can't find out) This is the node you got connection \
		credentials from."))

nodemgmt.anonymous = true
nodemgmt.addremove = true
nodemgmt.template  = "cbi/tblsection"

-- Name --
nodemgmt:option(Value, "name", translate("Name"))
nodemgmt.placeholder = ""

-- Address --
ia = nodemgmt:option(Value, "address", translate("Address"))
ia.datatype    = "ipaddr" -- return ip4addr(val) or ip6addr(val)
ia.placeholder = ""

-- Port --
ep = nodemgmt:option(Value, "port", translate("Port"))
ep.datatype    = "portrange"
ep.placeholder = ""

-- Public Key --
ip = nodemgmt:option(Value, "pubkey", translate("Public Key"))
ip.datatype    = "string"
ip.placeholder = ""

-- Password --
ac = nodemgmt:option(Value, "secret", translate("Password"))
ac.datatype    = "string"
ac.placeholder = ""

-- TODO
-- Node(s) to connect to manually.
-- ETHInterface -> connectTo -> "01:02:03:04:05:06":{"password":"a","publicKey":"b"}


----------------------
-- Cjdns   Settings --
----------------------
s = m:section(NamedSection, "config", "Cjdns Settings", translate("Cjdns Settings"))
s.addremove = false

----------
-- Tabs --
----------
s:tab("general",  translate("General Settings"))
s:tab("advanced", translate("Advanced Settings"))
s:tab("EzPaste",  translate("Easy Paste Node"))

----------------------
-- General Settings --
----------------------

e = s:taboption("general", Flag, "_init", translate("Enable Cjdns and NAT66 service"),
	translate("Toggles the start of both Cjdns and NAT66 services upon Boot"))
e.default  = 1
e.rmempty  = false


function e.cfgvalue(self, section)
	return luci.sys.init.enabled("cjdns") and self.enabled or self.disabled
end

function e.write(self, section, value)
	if value == "1" then
		luci.sys.call("/etc/init.d/cjdns enable >/dev/null")
		luci.sys.call("/etc/init.d/cjdns start >/dev/null")
	else
		luci.sys.call("/etc/init.d/cjdns stop >/dev/null")
		luci.sys.call("/etc/init.d/cjdns disable >/dev/null")
	end
end

-------------
-- Beacons --
-------------
bc = s:taboption("general", ListValue, "enable_beacons", translate("Enable Beacons"),
	translate("Select the preferred Beacons mode for ETHInterface"))
bc:value(0, translate("0 -- Disabled."))
bc:value(1, translate("1 -- Accept Beacons, this will cause Cjdns to accept incoming \
                      Beacon messages and try connecting to the Sender."))
bc:value(2, translate("2 -- Accept and Send Beacons to LAN broadcast address which \
                      contain a One-time Pad secret password."))

-------------
-- Logging --
-------------
s:taboption("general", Flag, "enable_stdlog", translate("Enable additional logging to logread"),
	translate("Puts extra debugging information into logread"))

-- s:taboption("general", Value, "cfg_pubkey", translate("Public Key"),
	-- translate("Your Multipass to Hyperboria")).rmempty = true

-- s:taboption("general", Value, "cfg_prvkey", translate("Private Key"),
	-- translate("Do not redistribute this key")).rmempty = true

-- port = s:taboption("general", Value, "port", translate("Port"))
-- port.datatype = "port"
-- port.default  = 5000

-----------------------
-- Advanced Settings --
-----------------------

s:taboption("advanced", Value, "uuid",          translate("Advanced Setting 1"))
s:taboption("advanced", Value, "serial_number", translate("Advanced Setting 2"))
s:taboption("advanced", Value, "model_number",  translate("Advanced Setting 3"))

ni = s:taboption("advanced", Value, "notify_interval", translate("Advanced Setting 4"))
ni.datatype    = "uinteger"
ni.placeholder = 30

lf = s:taboption("advanced", Value, "cjdns_lease_file", translate("Advanced Setting 8"))
lf.placeholder = "/var/log/cjdns.leases"

----------------------
--> Easy Paste Node --
----------------------
ez = s:taboption("EzPaste", Value, "EzPaste",
	             translate("Node information should be relayed by \
                           an Encrypted Pastebin: EZCrypt https://ezcrypt.it/"))
ez.template = "cbi/tvalue"
ez.rows     = 5
ez.datatype = "string"

----------------------
--> Generate Config --
----------------------
-- Button to auto-generate EzCrypt URL with routers /etc/cjdroute.conf info would be nice.










return m
