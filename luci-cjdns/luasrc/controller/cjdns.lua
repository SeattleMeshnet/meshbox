--[[
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>
Copyright 2008 Jo-Philipp Wich <xm@leipzig.freifunk.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

]]--

module("luci.controller.cjdns", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/cjdns") then
		return
	end

	local page

	page = entry({"admin", "services", "cjdns"},
			cbi("cjdns/cjdns", {autoapply=true}), _("cjdns"))
	page.dependent = true
	
	-- <%=luci.dispatcher.build_url
	entry({"admin", "services", "cjdns", "status"},   call("act_status")).leaf = true
	entry({"admin", "services", "cjdns", "nodemgmt"}, call("act_nodemgmt")).leaf = true
	entry({"admin", "services", "cjdns", "delete"},   call("act_delete")).leaf = true
end

function act_status()

	dkjson = require "dkjson" -- http://dkolf.de/src/dkjson-lua.fsl/home
	local conf = io.open("/etc/cjdroute.conf")
	local obj, pos, err = dkjson.decode(conf:read("*a"), 1, nil)

	for i = 1,#obj.interfaces.UDPInterface do
		local cjdstatus = { } 
		local udpif = obj.interfaces.UDPInterface[i]
		if (udpif == nil) then
			break
		end
		
		for w,x in pairs(udpif.connectTo) do
			num     = i
			node    = w
			nicknm  = x.name
			pubkey  = x.publicKey
			passwd  = x.password
			other   = 0
			latency = "Pinging..."
			cjdnsip = "Resolving..."


			x = require("uci").cursor()
			latency = x:get("network", "lan", "ifname")
			-- latency = x:get("cjdns", "A")

			if num and nicknm and node and pubkey and passwd and other then
				num   = tonumber(num)
				other = tonumber(other)
				cjdstatus[#cjdstatus+1] = {
								-- num     = #cjdstatus, 	-- current total #
								nicknm 	= nicknm,		-- name (could be nil)
								node    = node,			-- ipaddress:port
								pubkey  = publicKey,	-- publickey.k
								passwd  = passwd,		-- password
								other   = other,		-- not yet set
								latency = latency,		-- requires new functions
								cjdnsip = cjdnsip,		-- requires new functions
							}
			end
		end
		luci.http.prepare_content("application/json")
		luci.http.write_json(cjdstatus)
	end
	conf:close()
end


function act_nodemgmt()

	dkjson = require "dkjson" -- http://dkolf.de/src/dkjson-lua.fsl/home
	local conf = io.open("/etc/cjdroute.conf")
	local obj, pos, err = dkjson.decode(conf:read("*a"), 1, nil)

	for i = 1,#obj.interfaces.UDPInterface do
		local cjdstatus = { } 
		local udpif = obj.interfaces.UDPInterface[i]
		if (udpif == nil) then
			break
		end
		
		for w,x in pairs(udpif.connectTo) do
			num     = i
			node    = w
			nicknm  = x.name
			pubkey  = x.publicKey
			passwd  = x.password
			other   = 0
			latency = "Pinging..."
			cjdnsip = "Resolving..."


			x = require("uci").cursor()
			latency = x:get("network", "lan", "ifname")
			-- latency = x:get("cjdns", "A")

			if num and nicknm and node and pubkey and passwd and other then
				num   = tonumber(num)
				other = tonumber(other)
				cjdstatus[#cjdstatus+1] = {
								-- num     = #cjdstatus, 	-- current total #
								nicknm 	= nicknm,		-- name (could be nil)
								node    = node,			-- ipaddress:port
								pubkey  = publicKey,	-- publickey.k
								passwd  = passwd,		-- password
								other   = other,		-- not yet set
								latency = latency,		-- requires new functions
								cjdnsip = cjdnsip,		-- requires new functions
							}
			end
		end
		luci.http.prepare_content("application/json")
		luci.http.write_json(cjdstatus)
	end
	conf:close()
end

function act_delete(num)
	local idx = tonumber(num)
	local uci = luci.model.uci.cursor()

	if idx and idx > 0 then

		local lease_file = uci:get("cjdns", "config", "cjdns_lease_file")
		if lease_file and nixio.fs.access(lease_file) then
			luci.sys.call("sed -i -e '%dd' %q" %{ idx, lease_file })
		end

		luci.http.status(200, "OK")
		return
	end

	luci.http.status(400, "Bad request")
end
