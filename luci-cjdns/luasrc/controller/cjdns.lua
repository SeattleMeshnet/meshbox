--[[
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>
Copyright 2008 Jo-Philipp Wich <xm@leipzig.freifunk.net>
Copyright 2013-2014 William Fleurant <igel@hyperboria.ca>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

]]--

module("luci.controller.cjdns", package.seeall)

cjdns  = require "cjdns/init"
dkjson = require "dkjson"

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
	entry({"admin", "services", "cjdns", "peers"}, call("act_peers")).leaf = true
	entry({"admin", "services", "cjdns", "ping"}, call("act_ping")).leaf = true
end

function act_peers()
	config = cjdns.ConfigFile.new("/etc/cjdroute.conf")
	admin  = config:makeInterface()

	local page = 0
	local peers = {}

	while page do
		local response, err = admin:auth({
			q = "InterfaceController_peerStats",
			page = page
		})

		if err or response.error then
			luci.http.status(502, "Bad Gateway")
			luci.http.prepare_content("application/json")
			luci.http.write_json(response)
			return
		end

		for i,peer in pairs(response.peers) do
			peer.ipv6 = publictoip6(peer.publicKey)
			peers[#peers + 1] = peer
		end

		if response.more then
			page = page + 1
		else
			page = nil
		end
	end

	luci.http.status(200, "OK")
	luci.http.prepare_content("application/json")
	luci.http.write_json(peers)
end

function act_ping()
	config = cjdns.ConfigFile.new("/etc/cjdroute.conf")
	admin  = config:makeInterface()

	local response, err = admin:auth({
    q = "SwitchPinger_ping",
    path = luci.http.formvalue("label"),
    timeout = tonumber(luci.http.formvalue("timeout"))
  })

	if err or response.error then
		luci.http.status(502, "Bad Gateway")
		luci.http.prepare_content("application/json")
		luci.http.write_json(response)
		return
	end

	luci.http.status(200, "OK")
	luci.http.prepare_content("application/json")
	luci.http.write_json(response)
end

function publictoip6(publicKey)
	local process = io.popen("/usr/sbin/publictoip6 " .. publicKey, "r")
	local ipv6    = process:read()
	process:close()
	return ipv6
end

------------------------
-- Active cjdns nodes --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
function act_status()

	-- cjdns admin modules for Lua Written by Philip Horger,
	-- Integration of Lua bindings for LuCI by William Fleurant,
	-- Bugs? igel@hyperboria.ca [GnuPG 2B451511]

	cjdns 	 = require "cjdns/init"
	confpath = "/etc/cjdroute.conf"
	conf 	 = cjdns.ConfigFile.new(confpath)
	ai   	 = conf:makeInterface()

	local dkjson  		 = require "dkjson"  -- http://dkolf.de/src/dkjson-lua.fsl/home
	local cjdroute 		 = io.open("/etc/cjdroute.conf")
	local conf, pos, err = dkjson.decode(cjdroute:read("*a"), 1, nil)

	-- returns peerStats object of matched publicKey
	function RouterFunctions:peerStats(pubkey,element,page)
		if not element then
			local element = 'switchLabel'
		else
			local element = element
		end

		if page then page = page else page = 0 end

		while page do

			local response, err = self.ai:auth({
				q = "InterfaceController_peerStats",
				page = page,
			})

			for keys,switchen in pairs(response.peers) do
				if (response.peers[keys]['publicKey'] == pubkey) then
					return (response.peers[keys])
				end
			end

			if response.more then
				page = page + 1
			else
				page = nil
			end

		end
	end

	function RouterFunctions:switchpinger(path, data, timeout)
		local response, err = self.ai:auth({
			q = "SwitchPinger_ping",
			path = path,
			data = 0,
			timeout = ''
		})
		if err then
			return "Error"
		else
			return response
		end
	end

	function getConfType(conf,type) -- Sophana
		local curs=uci.cursor()
		local ifce={}
		curs:foreach(conf,type,
					 function(s)
						ifce[s[".name"]]=s
					 end)
		return ifce
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

	for i = 1,#conf.interfaces.UDPInterface do

		cjdstatus = { } -- print via luci.http.write_json
		local udpif = conf.interfaces.UDPInterface[i]

		if (udpif.connectTo ~= nil) then

		 for w,x in pairs(udpif.connectTo) do
			local num     = i
			local node    = w
			local name    = x.name
			local pubkey  = x.publicKey
			local passwd  = x.password
			local port    = x.port
			local address = x.address

			local xpktip6 = os.execute( "/usr/sbin/publictoip6" .. " " .. pubkey .. " > /tmp/.publictoip6" )
			local f       = assert(io.open("/tmp/.publictoip6", "r"))
			local cjdnsip = f:read()
			f:close()

			local pstatsobj = ai.router:peerStats(pubkey)

			if pstatsobj ~= nil and pstatsobj.state == 'ESTABLISHED' then
				latency 	= ai.router:switchpinger(pstatsobj.switchLabel).ms
				if latency == nil or latency >= 2000 then -- catch hiccup/timeout
					latency = 'Pinging...'
				else
					latency = latency .. "ms"
				end
				status 		= pstatsobj.state
			else
				latency 	= 'Pinging...'
				status 		= 'UNRESPONSIVE'
			end


			if name then
				-- Fill in the tables fields and allow XHR.poll to refresh on 5s intervals.
				cjdstatus[#cjdstatus+1] = {
					name 	= name,
					node    = node,
					cjdnsip = cjdnsip,
					latency = latency,
					other   = 0,
					status 	= status,
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

	if conf.interfaces.ETHInterface == nil then
		conf.interfaces.ETHInterface = { { connectTo = {} } }
	end

	for i = 1,#conf.interfaces.ETHInterface do

		local ethif = conf.interfaces.ETHInterface[i]

		if (ethif.connectTo ~= nil) then

		 for w,x in pairs(ethif.connectTo) do
			local num     = i
			local name    = x.name
			local pubkey  = x.publicKey
			local passwd  = x.password
			local address = w
			local node    = address
			local xpktip6 = os.execute( "/usr/sbin/publictoip6" .. " " .. pubkey .. " > /tmp/.publictoip6" )
			local f 	  = assert(io.open("/tmp/.publictoip6", "r"))
			local cjdnsip = f:read()
			f:close()

			local pstatsobj = ai.router:peerStats(pubkey)

			if pstatsobj ~= nil and pstatsobj.state == 'ESTABLISHED' then
				latency 	= ai.router:switchpinger(pstatsobj.switchLabel).ms
				if latency == nil or latency >= 2000 then -- catch hiccup/timeout
					latency = 'Pinging...'
				else
					latency = latency .. "ms"
				end
				status 		= pstatsobj.state
			else
				latency 	= 'Pinging...'
				status 		= 'UNRESPONSIVE'
			end

			if address then
				cjdstatus[#cjdstatus+1] = {
					name 	= name,
					node    = w,
					cjdnsip = cjdnsip,
					latency = latency,
					other   = 1,
					status 	= status
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

		if (iptif ~= nil) then


		 -- Note: We do some trickery to adhear to the saved uCI settings
		 -- 		solely for displaying more informative details of tunnel
		local xipeers = getConfType("cjdns","ipt_node")

		 for w,x in pairs(xipeers) do
			local name 		 = x.name
			local pubkey  	 = x.iptflow
			local pubkey  	 = x.publicKey
			local iptflow 	 = x.iptflow

			if iptflow == 'allowed' then
				other = 2
			elseif iptflow == 'outgoing' then
				other = 3
			else
				other = 4
			end

			local xpktip6 	 = os.execute( "/usr/sbin/publictoip6" .. " " .. pubkey .. " > /tmp/.publictoip6" )
			local f 	  	 = assert(io.open("/tmp/.publictoip6", "r"))
			local cjdnsip 	 = f:read()
			f:close()

			local pstatsobj = ai.router:peerStats(pubkey)

			if pstatsobj ~= nil and pstatsobj.state == 'ESTABLISHED' then
				latency 	= ai.router:switchpinger(pstatsobj.switchLabel).ms
				if latency == nil or latency >= 2000 then -- catch hiccup/timeout
					latency = 'Pinging...'
				else
					latency = latency .. "ms"
				end
				status 		= pstatsobj.state
			else
				latency 	= 'Pinging...'
				status 		= 'UNRESPONSIVE'
			end

			if pubkey then
				cjdstatus[#cjdstatus+1] = {
					name 	= name,
					node    = pubkey,
					cjdnsip = cjdnsip,
					latency = latency,
					other   = other,
					status 	= status,
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
	luci.http.status(200, "OK")
	return
end
