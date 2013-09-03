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

-----------
-- debug --
			-- get from uci
			-- x = require("uci").cursor()
			-- latency = x:get("cjdns", "config","log_output")
foo = "foo"
a = "\n"
dkjson = require "dkjson" -- http://dkolf.de/src/dkjson-lua.fsl/home
conf = io.open("/etc/cjdroute.conf")
obj, pos, err = dkjson.decode(conf:read("*a"), 1, nil)

igel = ""
for i = 1,#obj.interfaces.UDPInterface do
		node = { } 
		-- local cjdnode.node[0] = ""
		local udpif = obj.interfaces.UDPInterface[i]
		if (udpif == nil) then
			break
		end
		
		for w,x in pairs(udpif.connectTo) do
			node[i] = w
			name 	= w.name
			cnlname = w.name
			cnlpublicKey = w.publicKey
		end

		-- we should be getting /etc/cjdroute.config and putting it into:
		-- var tb = document.getElementById('cjdns_status_table');
				
		if name then
			-- num   = tonumber(num)
			-- other = tonumber(other)
			node[#node+1] = {
				cnlname 	 = node.name,
				cnlpublicKey = node.publicKey,
				cnlpassword  = node.password,
				cnlnode 	 = node,
			}

							-- ipaddress:port
							-- num     = #node, 	-- current total #
							-- nicknm 	= nicknm,		-- name (could be nil)
							-- TODO split on :port
							-- pubkey  = publicKey,	-- publickey.k
							-- passwd  = passwd,		-- password
							-- other   = other,		-- not yet set
							-- latency = latency,		-- requires new functions
							-- cjdnsip = cjdnsip,		-- requires new functions
						-- }
		end
		
			--[ 	Name    	]--
			--[ 	Address 	]--
			--[ 	Port    	]--
			--[ 	Public Key 	]--
			--[ 	Password 	]--
end
conf:close()
	-- blah=node[1]
	latency="HaH " .. node[1] .. " HaH"
	-- for i=1,#node do
	-- -- latency = table.concat( node, ", ")
	-- 	latency = latency .. " " .. node[i]
	-- end
	-- latency = node[0] ..  a .. node[1]
	-- latency .. a .. node[i]
-- end
-- ff = io.open("/etc/cjdroute.conf")
-- latency, pos, err = dkjson.decode(ff:read("*a"), 1, nil)
-- conf.interfaces.ETHInterface = { { bind = uci:get("network", "lan", "ifname"), beacon = 2, connectTo = {} } }
-- local peerfile = io.open("/usr/share/presetpeers")
-- if peerfile ~=	nill then
--     local peers, peerspos, peerserr = dkjson.decode(peerfile:read("*a"), 1, nill)
--     conf.interfaces.UDPInterface[1].connectTo = peers
-- end
-- f:close()


-- local save = io.open("/etc/cjdroute.conf", "w")
-- save:write( dkjson.encode (conf, { indent = true }))
-- save:close()

--  Project Meshnet  --
m = Map("cjdns", luci.util.pcdata(translate("Project Meshnet")),
	translate(latency))
-----------------------
-- Active Cjdns Nodes -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
m:section(SimpleSection).template  = "cjdns_status"



-------------
-- testing --
-- s = m:section(NamedSection, "config", "Cjdns Settings", translate("Cjdns Settings"))
-- s.addremove = false

function m.on_parse(self)
		-- do somthing if uci config is commited
		local http = require "luci.http"
		nodemgmt.anonymous = true

		-- latency = "Foo"
		-- nodemgmt.placeholder = latency


		-- WRITES BEACON 69696 to /tmp/cjdroute.conf
			-- dkjson = require("dkjson") -- http://dkolf.de/src/dkjson-lua.fsl/home
			-- uci = require("uci").cursor()

			-- local f = io.open("/etc/cjdroute.conf")

			-- local conf, pos, err = dkjson.decode(f:read("*a"), 1, nil)

			-- conf.interfaces.ETHInterface = { { bind = uci:get("network", "lan", "ifname"), beacon = 69696, connectTo = {} } }

			-- local peerfile = io.open("/usr/share/presetpeers")
			-- if peerfile ~=	nill then
			--     local peers, peerspos, peerserr = dkjson.decode(peerfile:read("*a"), 1, nill)
			--     conf.interfaces.UDPInterface[1].connectTo = peers
			-- end

			-- f:close()

			-- local save = io.open("/tmp/cjdroute.conf", "w")
			-- save:write( dkjson.encode (conf, { indent = true }))
			-- save:close()
		-- END WRITE


-- 		local file
-- 		local ok = { }
-- 		local save = io.open("/tmp/cjdroute.conf", "w")

-- -- for i = 1,#obj.interfaces.UDPInterface do
-- 	    for _, file in ipairs(self.parsechain) do
-- 			ok[#ok+1] = file
-- 				    	-- save:write( file )
	    	
-- 			-- file = "..." .. file "..."
-- 		end
-- 		for i=1,#ok do
-- 			save:write ( "loop " .. ok[#ok] .. "\n" ) 
-- 		end
	    
-- 	    save:close()
		-- http.redirect(luci.dispatcher.build_url("admin/services/ddns/"))

		-- http.redirect(luci.dispatcher.build_url("admin/services/ddns/"))


end
		-- luci.http.prepare_content("application/json")
		-- luci.http.write_json(cjdstatus)


-------------

---------------------
-- Cjdns Node List --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- nodemgmt = m:section(TypedSection, "node", translate("Cjdns Node List"),
-- nodemgmt = m:section(NamedSection, "config", "Cjdns Settings", translate("Cjdns Settings"))

-- nodemgmt = m:section(NamedSection, "node", "Cjdns Node List", translate("Cjdns Node List"))
-- m:section(SimpleSection).template  = "cjdns_nodemgmt"

nodemgmt = m:section(TypedSection, "node", translate("Cjdns Node List"),
	translate("First find the Cjdns ip of your upstream node. \
			  (Ask him/her if you can't find out) This is the node you got \
			  connection credentials from."))

nodemgmt.anonymous = true
nodemgmt.addremove = true
nodemgmt.template  = "cbi/tblsection"
-- nodemgmt.template  = "cjdns_nodemgmt"


btn = nodemgmt:option(Button, "_btn", translate("Add to CJDNS"))
function btn.write(self)


-- WRITES BEACON 69696 to /tmp/cjdroute.conf
	dkjson = require("dkjson") -- http://dkolf.de/src/dkjson-lua.fsl/home
	uci = require("uci").cursor()

	local f = io.open("/etc/cjdroute.conf")

	local conf, pos, err = dkjson.decode(f:read("*a"), 1, nil)
-- cbid.cjdns.cfg045e2e._btn

	foo = "foo"

	local hostname
	luci.model.uci.cursor():foreach("system", "system", function(s) hostname = s.hostname end)
	foo = hostname


	conf.interfaces.ETHInterface = 
	{ 
		{ 
			bind = foo, beacon = 35635, connectTo = {} 
			-- bind = uci:get("network", "lan", "ifname"), beacon = 35635, connectTo = {} 
		} 
	}

	
	-- conf.interfaces.UDPInterface.connectTo

 	 goal = conf.interfaces.UDPInterface.connectTo

        -- "connectTo" : {
        --   "072.513.51.4:4624" : {
        --     "name":"Joe Kool",
        --     "publicKey" : "zz1zzz1zzz1zzzz1zzz1zzz1zzz1zzz1zz1.k",
        --     "password" : "MUEs4hmR2WDeI * infinity"
        --   },





	-- {
	-- 	{
	-- 		connectTo 
	-- 	}
	-- }
-- = "Name"
-- = "Address"
-- = "Port"
-- = "Public Key"
-- = "Password"
	local peerfile = io.open("/usr/share/presetpeers")
	if peerfile ~=	nill then
	    local peers, peerspos, peerserr = dkjson.decode(peerfile:read("*a"), 1, nill)
	    conf.interfaces.UDPInterface[1].connectTo = peers
	end

	f:close()

	local save = io.open("/tmp/cjdroute.conf", "w")
	save:write( dkjson.encode (conf, { indent = true }))
	save:close()
-- END WRITE

end


--[[


s2 = m2:section(TypedSection, "_dummy", translate("SSH-Keys"),
	translate("Here you can paste public SSH-Keys (one per line) for SSH public-key authentication."))
s2.addremove = false
s2.anonymous = true
s2.template  = "cbi/tblsection"

function s2.cfgsections()
	return { "_keys" }
end

keys = s2:option(TextValue, "_data", "")
keys.wrap    = "off"
keys.rows    = 3
keys.rmempty = false

function keys.cfgvalue()
	return fs.readfile("/etc/dropbear/authorized_keys") or ""
end

function keys.write(self, section, value)
	if value then
		fs.writefile("/etc/dropbear/authorized_keys", value:gsub("\r\n", "\n"))
	end
end
]]--



-- for key,value in pairs(myTable) do --actualcode
--     myTable[key] = "foobar"
-- end


k = [[ 
"Name"
"Address"
"Port"
"Public Key"
"Password"
]]


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
-- ez.datatype = "string"
ez.default = "hello world"
ez.wrap = "off"
----------------------
--> Generate Config --
----------------------
-- Button to auto-generate EzCrypt URL with routers /etc/cjdroute.conf info would be nice.

-- x = require("uci").cursor()
-- lf.placeholder = x:get("network", "lan", "ifname")




return m
