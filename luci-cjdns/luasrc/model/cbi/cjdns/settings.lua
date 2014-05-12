m = Map("cjdns", translate("cjdns"),
  translate("Implements an encrypted IPv6 network using public-key \
    cryptography for address allocation and a distributed hash table for \
    routing. This provides near-zero-configuration networking, and prevents \
    many of the security and scalability issues that plague existing \
    networks."))

m.on_after_commit = function(self)
  os.execute("/etc/init.d/cjdns restart")
end

s = m:section(NamedSection, "cjdns")
s.addremove = false

s:tab("identity", translate("Identity"))
s:tab("peering",  translate("Peering"))
s:tab("admin",    translate("Admin Interface"))

-- Peering
apw = s:taboption("peering", Value, "inactivity_seconds", translate("Reestablish link if inactivite"),
      translate("Deadlink detection in seconds"))
apw.datatype = "integer(range(0,2048))"

-- Identity
node6 = s:taboption("identity", Value, "ipv6", translate("IPv6 Address"),
      translate("IPv6 tunnel address"))
node6.datatype = "ip6addr"
pbkey = s:taboption("identity", Value, "public_key", translate("Public Key"),
      translate("Your Multipass to Hyperboria"))
pbkey.datatype = "string"
prkey = s:taboption("identity", Value, "private_key", translate("Private Key"),
      translate("Do not redistribute this key"))
prkey.datatype = "string"

-- Admin Interface
apw = s:taboption("admin", Value, "admin_password", translate("Password for cjdns admin"),
      translate("Password for backend access to cjdadmin"))
apw.datatype = "string"
aip = s:taboption("admin", Value, "admin_address", translate("IP Address bound to cjdns admin"),
      translate("Default 127.0.0.1 or ::1 for all interfaces"))
aip.datatype = "ipaddr"
apt = s:taboption("admin", Value, "admin_port", translate("Port number bound to cjdns admin"),
      translate("Choose a valid 0-65535 port number"))
apt.datatype = "port"

-- UDP Interfaces
udp_interfaces = m:section(TypedSection, "udp_interface", translate("UDP Interfaces"),
  translate("These interfaces allow peering via public IP networks, such as the Internet"))
udp_interfaces.anonymous = true
udp_interfaces.addremove = true
udp_interfaces.template = "cbi/tblsection"

udp_interfaces:option(Value, "address", translate("IP Address")).datatype = "ipaddr"
udp_interfaces:option(Value, "port", translate("Port")).datatype = "portrange"

-- Ethernet Interfaces
eth_interfaces = m:section(TypedSection, "eth_interface", translate("Ethernet Interfaces"),
  translate("These interfaces allow peering via local networks (LAN)."))
eth_interfaces.anonymous = true
eth_interfaces.addremove = true
eth_interfaces.template = "cbi/tblsection"

eth_interfaces:option(Value, "bind", translate("Network Interface"))
eth_beacon = eth_interfaces:option(Value, "beacon", translate("Beacon Mode"))
eth_beacon:value(0, translate("0 -- Disabled"))
eth_beacon:value(1, translate("1 -- Accept beacons"))
eth_beacon:value(2, translate("2 -- Accept and send beacons"))
eth_beacon.datatype = "integer(range(0,2))"

return m
