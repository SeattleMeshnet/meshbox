common = require("cjdns/common")
require("cjdns/reload")

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

  local interfaces = cjdns.uci.get().ETHInterface

  conn:listen({
    ["network.interface"] = function(msg)
      for i, ethinterface in ipairs(interfaces) do
        if ethinterface.bind == msg.ifname then
          -- self.reload()
        end
      end
    end,
    ["cjdns.reload"] = function(msg)
      interfaces = cjdns.uci.get().ETHInterface
    end
  })

  uloop.run()
end

function Mgmt.reload()
  local admin = cjdns.uci.makeInterface()
  local config = cjdns.uci.get()

  local res, err = cjdns.reload(admin, config)
  if err then print(err) end

  os.execute("ubus send cjdns.reload '{}'")
end
