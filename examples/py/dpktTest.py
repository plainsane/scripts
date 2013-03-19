#!/usr/bin/env python
#needs http://dirtbags.net/py-pcap/py-pcap-1.0.tar.gz to run
import dpkt
import sys
import socket
dpkt_diff = '''
+++ dpkt-1.7/dpkt/ethernet.py   2011-01-25 15:29:31.000000000 -0800
@@ -23,6 +23,7 @@
 ETH_TYPE_DTP   = 0x2004        # Cisco Dynamic Trunking Protocol
 ETH_TYPE_REVARP   = 0x8035        # reverse addr resolution protocol
 ETH_TYPE_8021Q   = 0x8100        # IEEE 802.1Q VLAN tagging
+ETH_TYPE_8021AD = 0x9100        # IEEE 802.1AD (Q-in-Q)
 ETH_TYPE_IPX    = 0x8137        # Internetwork Packet Exchange
 ETH_TYPE_IP6   = 0x86DD        # IPv6 protocol
 ETH_TYPE_PPP  = 0x880B        # PPP
@@ -49,7 +50,7 @@
     _typesw = {}
     
     def _unpack_data(self, buf):
-        if self.type == ETH_TYPE_8021Q:
+        if self.type in (ETH_TYPE_8021Q, ETH_TYPE_8021AD):
             self.tag, self.type = struct.unpack('>HH', buf[:4])
             buf = buf[4:]
         elif self.type == ETH_TYPE_MPLS or \
'''
if hasattr(dpkt.ethernet, 'ETH_TYPE_8021AD') == False:
    print 'python module dpkt needs this diff applied'
    print dpkt_diff

pcapFile = dpkt.pcap.Reader(file(sys.argv[1]))
i = 1
for ts, payload in pcapFile:
    print '---------%d------------------------' % (i)
    eth = dpkt.ethernet.Ethernet(payload)
    if hasattr(eth, 'tag'):
        vlan = eth.tag
        print 'vlan', vlan
    else:
        print 'no vlan'

    if isinstance(eth.data, dpkt.arp.ARP):
        print 'arp packet found'
    elif isinstance(eth.data, dpkt.ip.IP):
        data = eth.data.data
        if isinstance(data, dpkt.tcp.TCP):
            print 'found tcp'
        elif isinstance(data, dpkt.udp.UDP):
            print 'found udp'
        else:
            continue
        srcIp = socket.inet_ntoa(eth.data.src)
        dstIp = socket.inet_ntoa(eth.data.dst)
        print srcIp, '--->', dstIp
    else:
        print 'have no idea about this type:', type(eth)
    i+=1
    print '------------------------------------'
