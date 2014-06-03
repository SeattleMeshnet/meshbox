meshbox
=======

This is the OpenWRT package feed for the [meshbox][meshbox] project. It provides UCI and LuCI integration for [cjdns][cjdns]. Tested with OpenWRT Barrier Breaker (trunk).

[meshbox]: http://fund.meshwith.me
[cjdns]: https://github.com/cjdelisle/cjdns

Integration into the OpenWRT buildroot is simple.

    $ git clone git://git.openwrt.org/openwrt.git
    $ cd openwrt

    $ cp feeds.conf.default feeds.conf
    $ echo 'src-git meshbox git://github.com/seattlemeshnet/meshbox.git' >> feeds.conf
    $ ./scripts/feeds update
    $ ./scripts/feeds install luci-cjdns

Then configure your firmware image: enable the luci-cjdns module, in addition to your usual settings, such as target system and profile. As usual, you'll need to hit space twice to make it `[*]` rather than `[M]`.

    $ make menuconfig
    LuCI -> Project Meshnet -> [*] luci-cjdns

Then save and close the configuration menu, and allow OpenWRT to resolve dependencies:

    $ make defconfig

Then build:

    $ make

If you have a multicore processor, you can build faster using `-j`, however the OpenWRT build process is not highly parallelized so your milage may vary.

    $ make -j 4

To update:

    $ ./scripts/feeds update


TODO
----

- [ ] Strip down the binary size and keep everything under 4MB
- [ ] Figure out NAT6 configuration
- [ ] Improve UI wording
- [ ] Introduce proper package versions
- [ ] Extend list of active peers
  - [ ] should show the used interface, and the password name
  - [ ] show data rx/tx since connected, other peerinfo data
- [ ] Visualize traffic in graphs
- [ ] Fill in useful default values for new UDP/ETHInterfaces
- [ ] Autogenerate passwords in the Peers UI
- [ ] Generate addpass.py-like password JSON
- [ ] Make paste-friendly textbox containing "yourip:port":{pass,key,name,info}
