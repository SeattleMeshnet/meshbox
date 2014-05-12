uci = require("luci.model.uci")
cursor = uci.cursor()

interface = uci.cursor_state():get("network", "lan", "ifname")

if interface then
  config = cursor:get_first("cjdns", "eth_interface")
  if not config then
    config = cursor:add("cjdns", "eth_interface")
  end

  cursor:set("cjdns", config, "bind", interface)
  cursor:set("cjdns", config, "beacon", "2")

  cursor:save("cjdns")
else
  print("network.lan.ifname empty")
end
