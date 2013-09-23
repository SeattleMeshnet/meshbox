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
                  cbi("cjdns/cjdns"), _("cjdns"))
                  -- cbi("cjdns/cjdns", {autoapply=true}), _("cjdns"))
	page.dependent = true
	
	-----------------------------------------
	-- Advanced Configuration Access (Tab) --
	-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	nopts = entry({"admin", "services", "cjdns", "Configuration Access"},
                   cbi("cjdns/advanced"), "Advanced Configuration Access", 1)
	nopts.leaf = false
	-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

	-- JavaScript
	-- See XHR.poll: <%=luci.dispatcher.build_url
	entry({"admin", "services", "cjdns", "status"}, call("act_status")).leaf = true
	entry({"admin", "services", "cjdns", "delete"}, call("act_delete")).leaf = true
end

------------------------
-- Active cjdns nodes --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
function act_status()

	local dkjson = require "dkjson" -- http://dkolf.de/src/dkjson-lua.fsl/home
	local cjdroute = io.open("/etc/cjdroute.conf")
	local conf, pos, err = dkjson.decode(cjdroute:read("*a"), 1, nil)

	for i = 1,#conf.interfaces.UDPInterface do

		local cjdstatus = { } -- print via luci.http.write_json
		local udpif = conf.interfaces.UDPInterface[i]

		if (udpif == nil) then
			break
		end
		
		for w,x in pairs(udpif.connectTo) do
			local num     = i -- used for act_delete(num)
			local node    = w -- cfg035387 (anonymous uci field (.name))
			local name    = x.name
			local pubkey  = x.publicKey
			local passwd  = x.password
			local port    = x.port
			local address = x.address
			local latency = "Pinging..." 	-- TODO
			local cjdnsip = "Resolving..." 	-- TODO
			-- local other   = 0 			-- TODO

			if address then -- and num and name and node and pubkey and passwd and other and port then
				-- Fill in the tables fields and allow XHR.poll to refresh on 5s intervals.

				-- BUG Need to use udpif.connectTo{} (UCI Is temporary and vaninty fix)
				-- BUG REPLACE: cfg035387 ("node" column) with host:port
						-- luci.sys.call("sed -i -e '%dd' %q" %{ i, conf })

				x 		= require("uci").cursor()
				node	= address .. ":" .. port

				cjdstatus[#cjdstatus+1] = {
					name 	= name, 	-- name (could be nil)
					node    = node,		-- ipaddress:port
					cjdnsip = cjdnsip, 	-- requires new functions
					latency = latency, 	-- requires new functions
				}
			end
		end -- end for pairs
		luci.http.prepare_content("application/json")
		luci.http.write_json(cjdstatus)
	end -- for conf.interfaces.UDPInterface{}
	cjdroute:close()
end

-----------------------------------------------------------
-- Remove node from "active" list of nodes (Keep in UCI) --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
function act_delete(num)
	-- NOT DONE
	luci.http.status(200, "OK")
	return
end
