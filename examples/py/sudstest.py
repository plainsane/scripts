import suds
import urllib2
import socket

t = suds.transport.https.HttpAuthenticated(username='admin', password='admin')
t.handler = urllib2.HTTPBasicAuthHandler(t.pm)
t.urlopener =  urllib2.build_opener(t.handler)
client = suds.client.Client('http://127.0.0.1/1.0/sdk?wsdl', transport=t, timeout=300)

# vnics = client.service.runVQLQuery("vm.name = 'McAfee vm 1' project vnic")
# for vnic in vnics:
#     for ip in vnic.ips:
#         socket.inet_aton(ip)
#         print ip
# qtag = client.factory.create('tag')
# qtag.name = 'Quarantine'
# print qtag
#qtag = client.service.createTag(qtag)
results = client.service.runVQLQuery("type = host")
print results
# print client
