#!/usr/bin/env lua

-- Make some new stuff up.
randomQuote = "<@cjd> I fucking hate Ducttape.c :( \n"
.. "<werecat> Well, it has to be better than krazyglue.c"
-- "    It's not a product, its a process. -cjd"

local meshLua_cmd = {}


--[[ Template to add to the menu ]]--

--[[

	status = { info = { "[XXX] command info for XXX" },
		exec = { function(x)
				--code...
			end 
			}
	},


]]--

meshLua_cmd = { 
	v = { info = { "\n\t--[[ Project Meshnet ]]--\n" ..  randomQuote .. "\n\n" } },

	l = { info = { "[l]ist all connected nodes" },
		exec = { function(x) 



				cjdns 	 = require "cjdns/init"
				confpath = "/etc/cjdroute.conf"
				conf 	 = cjdns.ConfigFile.new(confpath)
				ai   	 = conf:makeInterface()

				local dkjson  		 = require "dkjson"  -- http://dkolf.de/src/dkjson-lua.fsl/home
				local cjdroute 		 = io.open("/etc/cjdroute.conf")
				local conf, pos, err 	 = dkjson.decode(cjdroute:read("*a"), 1, nil)

				-- returns peerStats object of matched publicKey
				-- function RouterFunctions:peerStats(pubkey,element,page)
					if not element then
						local element = 'switchLabel'
					else
						local element = element
					end

					if page then page = page else page = 0 end

					while page do

						local response, err = ai:auth({
							q = "InterfaceController_peerStats",
							page = page,
						})

						for keys,switchen in pairs(response.peers) do
							if (response.peers[keys]['publicKey'] == pubkey) then
								print ('matched:',response.peers[keys])
							else
								print ('hit',response.peers[keys])
								print ('----')
								for k,v in pairs(response.peers[keys]) do
									print (k,v)
								end
							end
						end

						if response.more then
							page = page + 1
						else
							page = nil
						end

					end
				-- end







			end 
			}
	},


	h = { info = { "[h]yperboria - hype or not." },
		exec = { function(x) 
				print(math.random()) 
			end 
			}
	},
	
	b = { info = { "[b]roadcast meshbox-cjdns Wi-Fi" },
		exec = { function (x) 
				print(1)
			end
		}
	},

	p = { info = { "[p]reselected peers" },
		exec = { function (x)
				print("\t" .. "Timestamp: " .. os.time()) 
				
			end
			}
	},
	
	start = { info = { "[start] start cjdroute service" },
			exec = { function(x) 
				-- print("\t" .. " sh /etc/init.d/cjdns start")
				os.execute("/etc/init.d/cjdns start")
			end 
			}
	},

	stop = { info = { "[stop] stop cjdroute service" },
		exec = { function(x) 
				print("\t" .. " sh /etc/init.d/cjdns stop")
				os.execute("/etc/init.d/cjdns stop")
			end 
			}
	},
	
	restart = { info = { "[restart] restart cjdroute service" },
		exec = { function(x) 
				print("\t" .. " sh /etc/init.d/cjdns restart")
				os.execute("/etc/init.d/cjdns stop")
				os.execute("/etc/init.d/cjdns start")
			end 
			}
	},

	reconfigure = { info = { "[reconfigure] reconfigure cjdroute service" },
		exec = { function(x) 
				print("\t" .. " sh /etc/init.d/cjdns reconfigure")
				os.execute("/etc/init.d/cjdns reconfigure")
			end 
			}
	},

	status = { info = { "[status] status cjdroute service" },
		exec = { function(x) 
				print("\t" .. " sh /etc/init.d/cjdns status")
				-- local rS = 
				require('randomString')
				print(generate(14,14))
			end 
			}
	},

	u = { info = { "[u]dp peers list" },
		exec = { function (x)
				print("\t" .. "Timestamp: " .. os.time() )
				if arg[1] then
					local commander = arg[1]
					
					print("\t" .. "Commander: " .. arg[1])
					
					if x then
						local arguments = x
						
						print("\t" .. "Arguments: " .. x)
					end
				end
			end
		}
	},
	conf2uci = { info = { "[conf2uci] command info for XXX" },
		exec = { function(x) 
				print("\t" .. " sh -x /usr/share/cjdns_jsonpath.sh")
				os.execute("/usr/share/cjdns_jsonpath.sh")

			end 
			}
	},

	uci2conf = { info = { "[uci2conf] Save /etc/config/cjdns to /etc/cjdroute.conf" },
		exec = { function(x) 

				local dkjson = require("dkjson") -- http://dkolf.de/src/dkjson-lua.fsl/home
				local uci    = require("uci")

				local cjdroute = io.open("/etc/cjdroute.conf")
				local conf, pos, err = dkjson.decode(cjdroute:read("*a"), 1, nil)

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

				-- uCI cjdns section

				-- luci.model.uci.cursor():foreach("cjdns", "cjdns",
				uci.cursor():foreach("cjdns", "cjdns",
					function(cfg)
						enabled = cfg.enabled 		-- cjdns/nat66 (0, 1)
						logTo 	= cfg.logto_enable 	-- conf.logging NOT DONE
						bind_bi	= cfg.beacon_interface 	-- eg; eth5
						beacon 	= cfg.beacon_mode 	-- 0, 1, 2
						deadlnk = cfg.deadlink_reset
						cjd6ip 	= cfg.ipv6
						cjd6pub = cfg.publicKey
						cjd6prv = cfg.privateKey
						bind_pt = cfg.bind_hostport
						bind_ip = cfg.bind_hostip
						admpass	= cfg.admin_pass
						admport = cfg.admin_port
						admbind = cfg.admin_bind
						nobg 	= 1
						angel 	= 1

					end)
				--[[ ---------------- cjdroute.conf ---------------- ]]--

				-- admin settings
				conf.admin = {
						password = admpass,
						bind     = admbind .. ":" .. admport
					     }

				-- Authorized Passwords
				local auth_mgmt = getConfType("cjdns","node_auth_mgmt")
				conf.authorizedPasswords = { auth_mgmt }

				for i = 1,#conf.authorizedPasswords do
					hppw = { }
					local tap = conf.authorizedPasswords[i]
					if (tap == nil) then break end
					for w,x in pairs(tap) do
						password = x.password
						if password then
							hppw[#hppw+1] = { password = password }
						end
					end
					conf.authorizedPasswords = hppw
				end

				conf.resetAfterInactivitySeconds = tonumber(deadlnk)
				conf.logging 	= { logTo = "" }
				conf.ipv6 	= cjd6ip
				conf.publicKey 	= cjd6pub
				conf.privateKey = cjd6prv
				conf.noBackground = 1
				-- conf.noBackground = tonumber(nobg) This feature is not yet ready

				conf.security = {
					"nofiles",
					{
						setuser = "nobody",
						exemptAngel = tonumber(angel)
					}
				}

				-- UDPInterface section settings
				local peers = getConfType("cjdns","node")
				local bind = bind_ip .. ":" .. bind_pt
				conf.interfaces.UDPInterface =
				{
					{
						bind 	  = bind,
						connectTo = peers
					}
				}

				-- ETHInterface section settings
				local epeers = getConfType("cjdns","enode")
				conf.interfaces.ETHInterface =
				{
					{
						bind      = bind_bi,
						beacon    = tonumber(beacon),
						connectTo = epeers
					}
				}

				-- Router section settings
				local ipeers = getConfType("cjdns","ipt_node")
				conf.router = {
					interface = { type = "TUNInterface" },
					ipTunnel  = { {
							outgoingConnections = ipeers,
							allowedConnections  = ipeers
						    } }
				}

				for i = 1,#conf.interfaces.UDPInterface do

					local cjdstatus = {}
					local hpux = {}
					local udpif = conf.interfaces.UDPInterface[i]
					if (udpif == nil) then
						break
					end

					for w,x in pairs(udpif.connectTo) do
						num     	= i
						node    	= w
						password 	= x.password
						name 		= x.name
						publicKey 	= x.publicKey
						address 	= x.address

						if node then
							x 		= require("uci").cursor()
							address = x:get("cjdns",node,"address")
							port 	= x:get("cjdns",node,"port")

							if address and port then
								hp = address .. ":" .. port

								cjdstatus[#cjdstatus+1] = {} -- connectTo{node:port[#]{}}

								-- Stage new node:port[#]{var:val}
								hpux[hp] = { -- "1.2.3.4:1234:{}"
									name  	  = name,
									password  = password,
									publicKey = publicKey,
								}

								cjdstatus[#cjdstatus] = hpux
							end
						end
					end
					conf.interfaces.UDPInterface[i].connectTo = cjdstatus[#cjdstatus]
				end

				for i = 1,#conf.interfaces.ETHInterface do

					local cjdstatus_enode = {}
					local hpux = {}
					local ethif = conf.interfaces.ETHInterface[i]
					if (ethif == nil) then
						break
					end

					for w,x in pairs(ethif.connectTo) do
						num     	= i
						node    	= w
						password 	= x.password
						name 		= x.name
						publicKey 	= x.publicKey
						address 	= x.address

						if node then
							x 	= require("uci").cursor()
							address = x:get("cjdns",node,"enode")

							if address then
								hp = address

								cjdstatus_enode[#cjdstatus_enode+1] = {} -- connectTo{node:port[#]{}}

								-- Stage new node:port[#]{var:val}
								hpux[hp] = { -- "1.2.3.4:1234:{}"
									name  	  = name,
									password  = password,
									publicKey = publicKey,
								}

								cjdstatus_enode[#cjdstatus_enode] = hpux
							end
						end
					end
						conf.interfaces.ETHInterface[i].connectTo = cjdstatus_enode[#cjdstatus_enode]
				end

				for i = 1,#conf.router.ipTunnel do

					local cjdstatus_ipt    = {}
					local cjdstatus_ipt_ac = {}
					local cjdstatus_ipt_oc = {}
					local hpux  = {}
					local rtipt = conf.router.ipTunnel[i]
					if (rtipt == nil) then
						break
					end

					for w,x in pairs(rtipt.outgoingConnections) do
						num     	= i
						publicKey 	= x.publicKey
						flow 		= x.iptflow
						if (flow == 'outgoing' and publicKey) then
							cjdstatus_ipt_oc[#cjdstatus_ipt_oc+1] = publicKey
						end
					end
					conf.router.ipTunnel[i].outgoingConnections = cjdstatus_ipt_oc

					for w,x in pairs(rtipt.allowedConnections) do
						num     	= i
						name    	= x.name
						ip4Address 	= x.address
						ip6Address 	= x.address_6
						flow 		= x.iptflow

						if (flow == 'allowed' and publicKey) and (ip4Address or ip6Address) then
							cjdstatus_ipt[#cjdstatus_ipt+1] = {
								publicKey  = publicKey,
								name 	   = name,
								ip4Address = ip4Address,
								ip6Address = ip6Address,
							}
						end
					end
					conf.router.ipTunnel[i].allowedConnections = cjdstatus_ipt
				end
				cjdroute:close()

				local save = io.open("/etc/cjdroute.conf", "w")

				save:write( dkjson.encode (conf, { indent = true }))
				save:close()

			end 
			}
	},


}
 
function available_functions ()
	-- banner
	print(meshLua_cmd.v['info'][1])
	for k,v in pairs(meshLua_cmd) do
		-- skip banner.
		if(k ~= "v") then print("\t"..k.." .. "..v['info'][1]) end
	end
end

local keypunch = ""
local params = ""

if #arg == 0 then
	available_functions()
	repeat
		io.write("\n[meshLua]> ")
		io.flush()
		keypunch = io.read()
	until keypunch:len() ~= 0
end

if arg[1] then 
	keypunch = arg[1]
	params = table.concat(arg, " ", 2, end_index)
end

-- print('-=[meshbox]=- Command: '.. keypunch)
-- print('-=[meshbox]=- Param #: '.. params)


meshLua_cmd[keypunch]['exec'][1](params)

-- error("\n\n--Not-Today-Bub--")

if true == false then





if (uci.cursor():get("cjdns", "cjdns", "enabled") == '1') then
	os.execute("/etc/init.d/cjdns restart")
else
	os.execute("/usr/bin/logger -t cjdns cjdns not starting: DISABLED")
	os.execute("/etc/init.d/cjdns stop")
end


end
