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


	-- Hand json off to cjdns_status.htm javascript row fill
	for i = 1,#conf.interfaces.UDPInterface do

		cjdstatus = { } -- print via luci.http.write_json
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
			local other   = 1			-- TODO

			if address then -- and num and name and node and pubkey and passwd and other and port then
				-- Fill in the tables fields and allow XHR.poll to refresh on 5s intervals.
				cjdstatus[#cjdstatus+1] = {
					name 	= name, 	-- name (could be nil)
					node    = node,		-- ipaddress:port
					cjdnsip = cjdnsip, 	-- requires new functions
					latency = latency, 	-- requires new functions
					other   = other,
				}
			end
		end -- end for pairs
	end -- for conf.interfaces.UDPInterface{}

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

	for i = 1,#conf.interfaces.ETHInterface do
		-- local cjdstatus = { } -- print via luci.http.write_json
		local ethif = conf.interfaces.ETHInterface[i]
		if (ethif == nil) then
			break
		end

		for w,x in pairs(ethif.connectTo) do
			local num     = i
			local node    = w
			local name    = x.name
			local pubkey  = x.publicKey
			local passwd  = x.password
			local address = w -- mac address
			local latency = "Pinging..."
			local cjdnsip = "Resolving..."
			local other   = 0

			if address then
				cjdstatus[#cjdstatus+1] = {
					name 	= name,
					node    = address,
					cjdnsip = cjdnsip,
					latency = latency,
					other   = other,
				}
			end
		end -- end for pairs

	end -- for conf.interfaces.ETHInterface{}
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
	-- for i = 1,#conf.router.ipTunnel do
	-- 	-- local cjdstatus = { } -- print via luci.http.write_json
	-- iptun =  conf.router.ipTunnel
	-- iptun2 = conf.router.ipTunnel.outgoingConnections 	-- 3
	-- iptun3 = conf.router.ipTunnel.allowedConnections 	-- 2
					-- name 	= "Break_name",
					-- node    = "Break_address" .. #iptun, 	-- 0
					-- cjdnsip = "Break_cjdnsip" .. #iptun2,  	-- 3
					-- latency = "Break_latency" .. #iptun3, 	-- 2
					-- other   = "Break_other",


	-- for i = 1,#conf.router.ipTunnel do
		-- local cjdstatus = { } -- print via luci.http.write_json
		-- local tunnelout = conf.router.ipTunnel.outgoingConnections[1]
		-- if (tunnelout == nil) then
		-- #conf.router.ipTunnel.outgoingConnections,
		-- if tunnelout then
		-- 		cjdstatus[#cjdstatus+1] = {
		-- 			name 	= tunnelout,
		-- 			node    = tunnelout.ip4address,
		-- 			cjdnsip = tunnelout.publicKey,
		-- 			other   = 3,
		-- 			latency = "Pinging...",
		-- 			cjdnsip = "Resolving...",
		-- 		}
		-- 	-- break
		-- end

	luci.http.prepare_content("application/json")
	luci.http.write_json(cjdstatus)


	-- close conf
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
