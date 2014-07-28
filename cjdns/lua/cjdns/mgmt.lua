common = require("cjdns/common")
ubus   = require("ubus")
uloop  = require("uloop")

Mgmt = {}
common.mgmt = Mgmt

function Mgmt.listen()
  uloop.init()

  local conn = ubus.connect()
  if not conn then
    error("Failed to connect to ubus")
  end

  conn:listen({
    ["network.interface"] = function(msg)
      for k, v in pairs(msg) do print(k, v) end
    end,
    -- ["config.change"] = function(msg)
    --   for k, v in pairs(msg) do print(k, v) end
    -- end
  })

  uloop.run()
end

function Mgmt.reload()
  local admin = cjdns.uci.makeInterface()
  local config = cjdns.uci.get()

  admin:applyConfig(config)
end
