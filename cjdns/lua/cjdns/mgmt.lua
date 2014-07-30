common = require("cjdns/common")
require("cjdns/reload")

ubus   = require("ubus")
uloop  = require("uloop")

mgmt = {}
common.mgmt = mgmt

function mgmt.manage()
  uloop.init()

  local conn = ubus.connect()
  if not conn then
    error("Failed to connect to ubus")
  end

  conn:add({
    cjdns2 = {
      -- reloads the configuration, called by init script
      -- $ ubus call cjdns2 reload
      reload = {
        function(req, msg)
          local res, err = mgmt.reload()
          response = { added = res.added, removed = res.removed, error = err }
          conn:send("cjdns.reloaded", response)
          conn:reply(req, response)
        end, {}
      }
    }
  })

  -- FIXME: not getting the events yet, somehow
  conn:listen({
    -- netifd event for interface state changes (up, down), reloads config
    ["network.interface"] = function(msg)
      print("network.interface")
      for k, v in pairs(msg) do print("network.interface", k, v) end
    end,
    -- after config has been reloaded, we might want to do more stuff
    ["cjdns.reloaded"] = function(msg)
      print("cjdns.reloaded")
      for k, v in pairs(msg) do print("cjdns.reloaded", k, v) end
    end
  })

  uloop.run()
end

function mgmt.reload()
  local admin = cjdns.uci.makeInterface()

  return cjdns.reload(admin, admin.config)
end
