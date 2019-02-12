# Network Acces Layer

* Bare metal:
    * Test the cables
    * Check switch/NIC LEDs (green = 1Gbps, orange = 100 Mbps)
* VM (e.g. VirtualBox)
    * Check virtual network adapter type and settings
* Command: `ip link`
    * UP: ok, the interface is connected
    * NO-CARRIER: no signal on this interface

Next step: troubleshoot [Internet Layer](internet-layer.md)