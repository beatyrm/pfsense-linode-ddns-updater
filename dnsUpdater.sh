#!/bin/tcsh
#
# (c) Robert Beaty <beatyrm@beatytech.net>
#
# This source file is subject to the MIT license that is bundled
# with this source code in the file LICENSE.
# 

# define linode details
$apiKey = "";
# https://www.linode.com/api/dns/domain.list
$domainID = "";
# https://www.linode.com/api/dns/domain.resource.list
$resourceID = "";

# find WAN interface IP substitute dc1 with your specific interface
set wanIP = `ifconfig dc1 | grep inet | grep -v inet6 | sed 's/.*inet //g' | sed 's/.netmask.*//g'`

# get current IP
set dnsIP = `nslookup example.com | grep 'Address: ' | sed 's/Address: //g'`

# if they are not the same we need to update the entry
if($wanIP != $dnsIP) then
        # check that we don't have an internal IP or 0's
        if($wanIP != '0.0.0.0' && $wanIP !~ '192.168.') then
                # make the API call
                fetch -q -o - "https://api.linode.com/?api_key=$apiKey&api_action=domain.resource.update&DomainID=$domainID&ResourceID=$resourceID&Target=$wanIP"
                # log the change
                echo "[`date`] IP Change: WAN is $wanIP and DNS was $dnsIP: UPDATED" >> /var/log/dnsupdate.log;
        endif
endif
