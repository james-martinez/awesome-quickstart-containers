#!/bin/bash
echo "Configuration:"
echo "PROXY_SERVER=$PROXY_SERVER"
echo "PROXY_PORT=$PROXY_PORT"

echo "Setting config variables"
sed -i "s/vPROXY-SERVER/$PROXY_SERVER/g" /etc/redsocks.conf
sed -i "s/vPROXY-PORT/$PROXY_PORT/g" /etc/redsocks.conf

echo "Restarting redsocks and redirecting traffic via iptables"
/etc/init.d/redsocks restart
iptables -t nat -N REDSOCKS
iptables -t nat -A REDSOCKS -d 0.0.0.0/8 -j RETURN
iptables -t nat -A REDSOCKS -d 10.0.0.0/8 -j RETURN
iptables -t nat -A REDSOCKS -d 127.0.0.0/8 -j RETURN
iptables -t nat -A REDSOCKS -d 169.254.0.0/16 -j RETURN
iptables -t nat -A REDSOCKS -d 172.16.0.0/12 -j RETURN
iptables -t nat -A REDSOCKS -d 192.168.0.0/16 -j RETURN
iptables -t nat -A REDSOCKS -d 224.0.0.0/4 -j RETURN
iptables -t nat -A REDSOCKS -d 240.0.0.0/4 -j RETURN

iptables -t nat -A REDSOCKS -p tcp --dport 80 -j REDIRECT --to-port 12345
iptables -t nat -A REDSOCKS -p tcp --dport 443 -j REDIRECT --to-port 12345
iptables -t nat -A REDSOCKS -p tcp --dport 11371 -j REDIRECT --to-ports 12346

iptables -t nat -A OUTPUT -p tcp -j REDSOCKS

iptables -t nat -A PREROUTING -p tcp --dport 11371 -j REDSOCKS
iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDSOCKS
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDSOCKS


# Run app
echo "Testing http access using: https://google.com "
curl  -vk https://google.com

while true; do sleep 1000; done
