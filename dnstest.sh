#!/usr/bin/env bash

command -v bc > /dev/null || { echo "bc was not found. Please install bc."; exit 1; }
{ command -v drill > /dev/null && dig=drill; } || { command -v dig > /dev/null && dig=dig; } || { echo "dig was not found. Please install dnsutils."; exit 1; }



NAMESERVERS=`cat /etc/resolv.conf | grep ^nameserver | cut -d " " -f 2 | sed 's/\(.*\)/&#&/'`

PROVIDERS="
8.8.8.8#Google
8.8.4.4#Google1
9.9.9.9#Quad9
149.112.112.112#Quad9
208.67.222.222#OpenDNS
208.67.220.220#OpenDNS1
1.1.1.1#Cloudflare
1.0.0.1#Cloudflare1
185.228.168.9#CleanBrowsing
185.228.169.9#CleanBrowsing1
76.76.19.19#Alternate
76.223.122.150#Alternate1
94.140.14.14#AdGuard	
94.140.15.15#AdGuard1
84.200.69.80#DNS
84.200.70.40#DNS1
8.26.56.26#Comodo
8.20.247.20#Comodo1
205.171.3.65#CenturyLink
205.171.2.65#CenturyLink1
195.46.39.39#SafeSDN
195.46.39.40#SafeSDN1
159.89.120.99#OpenNIC
134.195.4.2#OpenNIC
216.146.35.35#Dyn
216.146.36.36#Dyn1
45.33.97.5#FreeDNS
37.235.1.177#FreeDNS1
91.239.100.100#UncensoredDNS
89.233.43.71#UncensoredDNS
74.82.42.42#Hurricane
64.6.64.6#Neustar
64.6.65.6#Neustar1
45.77.165.194#Fourth
45.32.36.36#Fourth1
76.76.2.0#ControlD
76.76.10.0#ControlD1
"

# Domains to test. Duplicated domains are ok
DOMAINS2TEST="www.google.com amazon.com facebook.com www.youtube.com www.reddit.com  wikipedia.org twitter.com gmail.com www.google.com whatsapp.com"


totaldomains=0
printf "%-18s" ""
for d in $DOMAINS2TEST; do
    totaldomains=$((totaldomains + 1))
    printf "%-8s" "test$totaldomains"
done
printf "%-8s" "Average"
echo ""


for p in $NAMESERVERS $PROVIDERS; do
    pip=${p%%#*}
    pname=${p##*#}
    ftime=0

    printf "%-18s" "$pname"
    for d in $DOMAINS2TEST; do
        ttime=`$dig +tries=1 +time=2 +stats @$pip $d |grep "Query time:" | cut -d : -f 2- | cut -d " " -f 2`
        if [ -z "$ttime" ]; then
	        #let's have time out be 1s = 1000ms
	        ttime=1000
        elif [ "x$ttime" = "x0" ]; then
	        ttime=1
	    fi

        printf "%-8s" "$ttime ms"
        ftime=$((ftime + ttime))
    done
    avg=`bc -lq <<< "scale=2; $ftime/$totaldomains"`

    echo "  $avg"
done


exit 0;
