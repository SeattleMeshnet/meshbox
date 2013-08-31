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
	translate("cjd's ideology that networks should be easy to set up, protocols should scale up smoothly, and security should be ubiquitous."))

m:section(SimpleSection).template  = "cjdns_status"

s = m:section(NamedSection, "config", "cjdns", translate("cjdns settings"))
s.addremove = false
s:tab("general",  translate("General Settings"))
s:tab("advanced", translate("Advanced Settings"))

e = s:taboption("general", Flag, "_init", translate("Start Cjdns and NAT66 service"))
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

s:taboption("general", Flag, "enable_cjdns", translate("Enable Cjdns functionality")).default = "1"
s:taboption("general", Flag, "enable_nat66", translate("Enable NAT66 functionality")).default = "1"

s:taboption("general", Flag, "secure_mode", translate("Enable Beacons"),
	translate("Allow Beacons set to 2")).default = "1"

s:taboption("general", Flag, "log_output", translate("Enable additional logging to logread"),
	translate("Puts extra debugging information into logread (which can be redirected to remote syslog-ng)"))

s:taboption("general", Value, "download", translate("Public Key"),
	translate("Your Multipass to Hyperboria")).rmempty = true

s:taboption("general", Value, "upload", translate("Private Key"),
	translate("Do not redistribute this key")).rmempty = true

port = s:taboption("general", Value, "port", translate("Port"))
port.datatype = "port"
-- port.default  = 5000


s:taboption("advanced", Flag, "system_uptime", translate("Report system instead of daemon uptime")).default = "1"

s:taboption("advanced", Value, "uuid", translate("Advanced Setting 1"))
s:taboption("advanced", Value, "serial_number", translate("Advanced Setting 2"))
s:taboption("advanced", Value, "model_number", translate("Advanced Setting 3"))

ni = s:taboption("advanced", Value, "notify_interval", translate("Advanced Setting 4"))
ni.datatype    = "uinteger"
ni.placeholder = 30

ct = s:taboption("advanced", Value, "clean_ruleset_threshold", translate("Advanced Setting 5"))
ct.datatype    = "uinteger"
ct.placeholder = 20

ci = s:taboption("advanced", Value, "clean_ruleset_interval", translate("Advanced Setting 6"))
ci.datatype    = "uinteger"
ci.placeholder = 600

pu = s:taboption("advanced", Value, "presentation_url", translate("Advanced Setting 7"))
pu.placeholder = "http://[fc3g:31d4:3g2d:24tf:4g32:4g23:42d2]/"

lf = s:taboption("advanced", Value, "cjdns_lease_file", translate("Advanced Setting 8"))
lf.placeholder = "/var/log/cjdns.leases"


s2 = m:section(TypedSection, "perm_rule", translate("Cjdns Node List"),
	translate("First find the Cjdns ip of your upstream node. \
		(Ask him/her if you can't find out) This is the node you got connection \
		credentials from."))

s2.template  = "cbi/tblsection"
-- s2.sortable  = true
s2.anonymous = true
s2.addremove = true
-- Node	Cjdns IP	Latency	Other	Status
s2:option(Value, "comment", translate("Node"))
s2.placeholder = "Igel_VPS"

ep = s2:option(Value, "ext_ports", translate("Cjdroute Port"))
ep.datatype    = "portrange"
ep.placeholder = "0-65535"

ia = s2:option(Value, "int_addr", translate("Node IPv4"))
ia.datatype    = "ip4addr"
ia.placeholder = "0.0.0.0"

ip = s2:option(Value, "int_ports", translate("Cjdns Public Key"))
ip.datatype    = "portrange"
ip.placeholder = "...hhj3hk.k"

ac = s2:option(ListValue, "action", translate("Cjdroute Flow"))
ac:value("incoming")
ac:value("outgoing")

return m
