--[[
LuCI - Lua Configuration Interface

Copyright 2011 Jo-Philipp Wich <xm@subsignal.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id: custom.lua 8108 2011-12-19 21:16:31Z jow $
]]--
local fs = require "nixio.fs"

local f = SimpleForm("advanced",
	translate("Configuration Access"),
	translate("Complete access to /etc/cjdroute.conf"))

local o = f:field(Value, "_advanced")

o.template = "cbi/tvalue"
o.rows = 25

function o.cfgvalue(self, section)
	return fs.readfile("/etc/cjdroute.conf")
end

function o.write(self, section, value)
	value = value:gsub("\r\n?", "\n")
	fs.writefile("/etc/cjdroute.conf", value)
end

return f