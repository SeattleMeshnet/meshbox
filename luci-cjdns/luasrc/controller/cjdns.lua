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

		if (udpif.connectTo ~= nil) then

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
			local other   = 0

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
		end -- end for sanity
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

		local ethif = conf.interfaces.ETHInterface[i]

		if (ethif.connectTo ~= nil) then

		 for w,x in pairs(ethif.connectTo) do
			local num     = i
			local name    = x.name
			local pubkey  = x.publicKey
			local passwd  = x.password
			local address = w -- mac address
			local node    = address
			local latency = "Pinging..."
			local cjdnsip = "Resolving..."
			local other   = 1

			if address then
				cjdstatus[#cjdstatus+1] = {
					name 	= name,
					node    = w,
					cjdnsip = cjdnsip,
					latency = latency,
					other   = other,
				}
			end
		 end -- end for pairs
		end -- end for sanity
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

	for i = 1,#conf.router.ipTunnel do

		local iptif = conf.router.ipTunnel[i]

		if (iptif.allowedConnections ~= nil) then

		 for w,x in pairs(iptif.allowedConnections) do
			local name 		 = x.name
			local publicKey  = x.publicKey
			local ip4Address = x.ip4Address
			local ip6Address = x.ip6Address
			local latency 	 = "Pinging..."
			local cjdnsip 	 = "Resolving..."
			local other   	 = 2  -- BUG being duped for all below. how?
			local y 		 = "|"

			local address 	 = "Resolving..."
			-- TODO check if not valid ip, ip6,
			-- 	then check how to resolve domainname, or /etc/hosts

			-- Display address Order by both, v4, v6, unresolved.
			if ip4Address and ip6Address  then
				address = ip4Address .. y .. ip6Address
			elseif
				(ip4Address ~= nil) then address = ip4Address
			else
				address = ip6Address
			end

			if publicKey then -- and (ip4Address or ip6Address) then
				cjdstatus[#cjdstatus+1] = {
					name 	= name,
					node    = address,
					cjdnsip = cjdnsip,
					latency = latency,
					other   = other,
				}
			end
		 end -- end for pairs
		end -- end for sanity

		if (iptif.outgoingConnections ~= nil) then

		 for w,x in pairs(iptif.outgoingConnections) do
			local name 		 = x.name
			local publicKey  = x.publicKey
			local other   	 = 3
			local latency 	 = "Pinging..."
			local cjdnsip 	 = "Resolving..."
			local address 	 = "Resolving..."

			if publicKey then -- and (ip4Address or ip6Address) then
				cjdstatus[#cjdstatus+1] = {
					name 	= name,
					node    = publicKey,
					cjdnsip = cjdnsip,
					latency = latency,
					other   = other,
				}
			end
		 end -- end for pairs
		end -- end for sanity

	end -- for conf.router.ipTunnel{}

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
